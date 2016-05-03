class Contest < ActiveRecord::Base
	resourcify
	has_many :long_submissions
	
	validates :name, presence: true, uniqueness: true
	validates :number_of_short_questions, presence: true
	validates :number_of_long_questions, presence: true
	validates :start_time, presence: true
	validates :end_time, presence: true
end
