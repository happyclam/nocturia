class Setting < ActiveRecord::Base
  belongs_to :user, :touch => true
  validates :user, :presence => true
  validates :duration, :presence => true, :inclusion => {:in => (5..45)}
  validates :startdateymd, :presence => true
  validates :enddateymd, :presence => true
end
