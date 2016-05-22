class Contest < ActiveRecord::Base
	resourcify

	has_many :long_submissions
	
	has_many :short_problems
	has_many :short_submissions, through: :short_problems
	has_many :users, through: :short_submissions
	
	validates :name, presence: true, uniqueness: true
	validates :number_of_short_questions, presence: true
	validates :number_of_long_questions, presence: true
	validates :start_time, presence: true
	validates :end_time, presence: true

	def self.next_contest
		after_now = Contest.where("end_time > ?", Time.now)
		return after_now.order("end_time")[0]
	end

	def self.prev_contests
		prev_contests = Contest.where("end_time < ?", Time.now)
		return prev_contests.limit(5).order("end_time desc")
	end
end
