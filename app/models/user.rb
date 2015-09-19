class User < ActiveRecord::Base
  has_one :setting, :dependent => :destroy
  validates :provider, :uid, :presence => true

  def self.create_with_omniauth(auth)
p "User::create_with_omniauth"
    #WithingsAPIが初回認証時にユーザ情報(info)を返してこないので、重くなるけどさっそくユーザ情報取得API呼び出し
    url = WITHINGS_URI + '/v2/user'
    params = {:action => :getbyuserid, :userid => auth.uid}
    params.merge!({
                    :oauth_consumer_key => CONSUMER_KEY,
                    :oauth_nonce => rand(10 ** 30).to_s(16),
                    :oauth_signature_method => 'HMAC-SHA1',
                    :oauth_timestamp => Time.now.to_i,
                    :oauth_version => '1.0',
                    :oauth_token => auth.credentials.token
                  })
    params = params.to_a.map() do |item|
      [item.first.to_s, CGI.escape(item.last.to_s)]
    end.sort
    param_string = params.map() {|key, value| "#{key}=#{value}"}.join('&')
    base_string = ['GET', CGI.escape(url), CGI.escape(param_string)].join('&')
    secret = [CONSUMER_SECRET, auth.credentials.secret].join('&')
    digest = OpenSSL::HMAC.digest('sha1', secret, base_string)
    signature = Base64.encode64(digest).chomp.gsub( /\n/, '' )
    uri_string = url + '?' + param_string + '&oauth_signature=' + CGI.escape(signature)

    Net::HTTP.version_1_2
    uri = URI.parse(uri_string)
    json = Net::HTTP.get(uri)
    results = JSON.parse(json)

    startdate = (Time.now - DEFAULT_DURATION * 24 * 60 * 60).strftime("%Y-%m-%d")
    enddate = Time.now.strftime("%Y-%m-%d")
    setting = Setting.new(duration: DEFAULT_DURATION, startdateymd: startdate, enddateymd: enddate)
    setting.user = create! do |user|
      user.provider = auth.provider
      user.uid = auth.uid
      user.name = (results["body"]["users"][0]["shortname"]) ? results["body"]["users"][0]["shortname"] : "Jane Doe"
      user.deviceid = auth.extra.access_token.params[:deviceid]
    end
    setting.save
    return setting.user
  end

  def get_sleep_summary(startdate, enddate, sessions)
p "user.get_sleep_summary"
    url = WITHINGS_URI + '/v2/sleep'
    params = {:action => :getsummary, :userid => self.uid}
    params.merge!({
                    :oauth_consumer_key => CONSUMER_KEY,
                    :startdateymd => startdate,
                    :enddateymd => enddate,
                    :oauth_nonce => rand(10 ** 30).to_s(16),
                    :oauth_signature_method => 'HMAC-SHA1',
                    :oauth_timestamp => Time.now.to_i,
                    :oauth_version => '1.0',
                    :oauth_token => sessions[:access_token]
                  })
    results = exec_api(url, params, sessions)

  end

  def draw_graph(results)
    merged = Array.new
    dummy = {
      "date"=>"2000-01-01",
      "data"=>
             {"wakeupduration"=>0,
              "lightsleepduration"=>0,
              "deepsleepduration"=>0,
              "wakeupcount"=>0,
              "durationtosleep"=>0}
            }
    results["body"]["series"].sort{|a, b| a["date"] <=> b["date"]}.each{|o|
      buf = o.clone
      if dummy["date"] == o["date"]
        dummy["data"]["wakeupduration"] += o["data"]["wakeupduration"]
        dummy["data"]["lightsleepduration"] += o["data"]["lightsleepduration"]
        dummy["data"]["deepsleepduration"] += o["data"]["deepsleepduration"]
        dummy["data"]["wakeupcount"] += o["data"]["wakeupcount"]
        dummy["data"]["durationtosleep"] += o["data"]["durationtosleep"]
        merged.pop
        merged.push(dummy.clone)
      else
        merged.push(buf)
        dummy = o.clone
      end
    }
    wakeuped = Array.new
    datevalues = Array.new
    sleeping = Array.new
    counter = 0
    sum = 0.0
    merged.each {|o|
      counter += 1
      hours = o["data"]["lightsleepduration"].divmod(60 * 60)
      lightsleepduration = (BigDecimal(hours[0].to_s) + BigDecimal((hours[1].divmod(60)[0] / 60.0).to_s).round(2)).to_f
      hours = o["data"]["deepsleepduration"].divmod(60 * 60)
      deepsleepduration = (BigDecimal(hours[0].to_s) + BigDecimal((hours[1].divmod(60)[0] / 60.0).to_s).round(2)).to_f
      hours = o["data"]["wakeupduration"].divmod(60 * 60)
      wakeupduration = (BigDecimal(hours[0].to_s) + BigDecimal((hours[1].divmod(60)[0] / 60.0).to_s).round(2)).to_f
      wakeuped << o["data"]["wakeupcount"]
      datevalues << o["date"]
      total = deepsleepduration + lightsleepduration + wakeupduration
      sleeping << [deepsleepduration, lightsleepduration, wakeupduration]
      sum += o["data"]["wakeupcount"]
    }

    graph_data = LazyHighCharts::HighChart.new("graph") do |f|
      f.title(:text => self.name)
      # f.tooltip(:pointFormat => '{series.name}: {point.y}<br />',
      #           :shared => true,
      #           :useHTML => true,
      #           :style => {margin: 0}
      #           )
      f.xAxis(:title => {:text => "日付"}, :categories => datevalues)
      f.yAxis(
        :title => {
          :text => "睡眠時間(時間) & 目覚め回数(回)"
        },
        :stackLabels => {
          :enabled => true
        }
      )
      f.legend(:shadow => false)
      f.plotOptions(
        :column => {
          :stacking => 'normal',
          :dataLabels => {:enabled => true,
                          :color => 'black'
                         }
        }
      )
      f.series(:type => 'column', :name => '目覚めてる', :color => '#FDBB5C', :data => sleeping.transpose[2])
      f.series(:type => 'column', :name => '浅い眠り', :color => '#7AA2D5', :data => sleeping.transpose[1])
      f.series(:type => 'column', :name => '深い眠り', :color => '#285ABD', :data => sleeping.transpose[0])
      f.series(:type => 'spline', :name => "目覚めた回数", :color => 'red', :data => wakeuped)
    end
    return graph_data, (sum / counter)
  end

  private
  def exec_api(url, params, sessions)
    params = params.to_a.map() do |item|
      [item.first.to_s, CGI.escape(item.last.to_s)]
    end.sort
    param_string = params.map() {|key, value| "#{key}=#{value}"}.join('&')
    base_string = ['GET', CGI.escape(url), CGI.escape(param_string)].join('&')
    secret = [CONSUMER_SECRET, sessions[:access_token_secret]].join('&')
    digest = OpenSSL::HMAC.digest('sha1', secret, base_string)
    signature = Base64.encode64(digest).chomp.gsub( /\n/, '' )
    uri_string = url + '?' + param_string + '&oauth_signature=' + CGI.escape(signature)

    Net::HTTP.version_1_2
    uri = URI.parse(uri_string)
    json = Net::HTTP.get(uri)
    results = JSON.parse(json)
  end

end
