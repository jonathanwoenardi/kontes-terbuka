module ContestAttributes
  extend ActiveSupport::Concern

  def to_s
    name
  end

  def to_param
    "#{id}-#{name.downcase.gsub(/[^0-9A-Za-z ]/, '').tr(' ', '-')}"
  end

  def started?
    Time.zone.now >= start_time
  end

  def ended?
    Time.zone.now >= end_time
  end

  def feedback_closed?
    Time.zone.now >= feedback_time
  end

  def currently_in_contest?
    started? && !ended?
  end

  def max_score
    short_problems.length + LongProblem::MAX_MARK * long_problems.length
  end

  def results(*includes)
    scores(includes).select do
      'rank() over(order by marks.total_mark DESC) as rank'
    end
  end

  # This method generates an array containing the number of people getting
  # a certain total score, excluding veterans.
  def array_of_scores
    res = Array.new(max_score + 1).fill(0)
    scores(user: :roles).each do |uc|
      res[uc.total_mark] += 1 unless uc.user.has_cached_role?(:veteran)
    end
    res
  end

  # Returns a matrix of feedback answers (2d array).
  # Main array is an array of answers by the same user contest ID.
  # In each sub-array there are answers sorted by feedback questions ID.
  def feedback_answers_matrix
    hash = Hash.new { |h, k| h[k] = {} }

    feedback_answers.each do |fa|
      hash[fa.user_contest_id][fa.feedback_question_id] = fa.answer
    end

    feedback_questions.each do |fq|
      hash.each { |_ucid, h| h[fq.id] = '' if h[fq.id].nil? }
    end

    res = []
    hash.each do |_ucid, h|
      res.append(h.sort_by { |fqid, _ans| fqid }.map { |arr| arr[1] })
    end
    res
  end

  # This method finds all user_contests who fills
  # all feedback questions in that particular contest.
  def full_feedback_user_contests(*includes)
    filtered_query = user_contests.processed

    feedback_questions.each do |fq|
      filtered_query =
        filtered_query
        .joins do
          UserContest.include_feedback_answers(fq.id)
                     .as("feedback_answers_#{fq.id}")
                     .on do
                       id == __send__("feedback_answers_#{fq.id}").id
                     end
        end
    end
    filtered_query.includes(includes)
  end

  # This method finds all user_contests who has at least one feedback question
  # not filled in that particular contest.
  def not_full_feedback_user_contests(*includes)
    full = full_feedback_user_contests.pluck(:id)
    all = user_contests.pluck(:id)
    remaining = all - full
    UserContest.where(id: remaining).includes(includes)
  end

  private

  def scores(*includes)
    filtered_query = user_contests.processed

    long_problems.each do |long_problem|
      filtered_query =
        filtered_query
        .joining do
          UserContest.include_long_problem_marks(long_problem.id)
                     .as("long_problem_marks_#{long_problem.id}")
                     .on do
                       id == __send__('long_problem_marks_' \
                                                     "#{long_problem.id}").id
                     end
        end.selecting do
          __send__("long_problem_marks_#{long_problem.id}")
            .__send__("problem_no_#{long_problem.id}")
        end
    end
    filtered_query.includes(includes)
  end
end
