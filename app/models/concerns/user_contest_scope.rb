module UserContestScope
  extend ActiveSupport::Concern

  private

  included do
    # Show short marks on model objects. Short marks only
    # Usage: UserContest.short_marks
    scope :short_marks, lambda {
      joining { short_submissions.outer }
        .joining { short_problems.outer }
        .group(:id)
        .select(:id)
        .select('user_contests.id as id, sum(case when ' \
        'short_submissions.answer = short_problems.answer then 1 else 0 end) ' \
        'as short_mark')
    }

    # Show long marks on model objects. Long marks only
    scope :long_marks, lambda {
      joining { long_submissions.outer }
        .group(:id)
        .select(:id)
        .select('user_contests.id as id, ' \
        'sum(coalesce(long_submissions.score, 0)) as long_mark')
    }

    # Show both short marks and long marks. Short and long marks
    scope :include_marks, lambda {
      joining do
        UserContest.short_marks.as(short_marks).on { id == short_marks.id }
      end.joining do
        UserContest.long_marks.as(long_marks).on { id == long_marks.id }
      end.selecting do
        ['user_contests.*', 'short_marks.short_mark',
         'long_marks.long_mark', '(short_marks.short_mark + ' \
                   'long_marks.long_mark) as total_mark']
      end
    }

    # Show marks + award (emas/perak/perunggu)
    scope :processed, lambda {
      joining { UserContest.include_marks.as(marks).on { id == marks.id } }
        .joining { contest }
        .selecting do
        ['user_contests.*',
         'marks.short_mark',
         'marks.long_mark',
         'marks.total_mark',
         "case when marks.total_mark >= gold_cutoff then 'Emas'
               when marks.total_mark >= silver_cutoff then 'Perak'
               when marks.total_mark >= bronze_cutoff then 'Perunggu'
               else '' end as award"]
      end.ordering { marks.total_mark.desc }
    }

    # Given a long problem ID, this shows table of user contest id
    # + long problem marks for that long problem.
    scope :include_long_problem_marks, lambda { |long_problem_id|
      joining { long_submissions.outer }
        .where.has { long_submissions.long_problem_id == long_problem_id }
        .selecting do
          ['user_contests.id as id', 'long_submissions.score as ' \
                     "problem_no_#{long_problem_id}"]
        end
    }

    # Given a feedback question ID, this shows table of user contest id
    # + feedback answer for that feedback question. (INNER JOIN)
    scope :include_feedback_answers, lambda { |feedback_question_id|
      joining { feedback_answers }
        .where.has { feedback_answers.feedback_question_id ==
                     feedback_question_id }
        .selecting do
          ['user_contests.id as id', 'feedback_answers.answer as ' \
                     "feedback_question_no_#{feedback_question_id}"]
        end
    }

    CUTOFF_CERTIFICATE = 1
    # Add this scope to filter that has high enough score to get certificates
    scope :eligible_score, lambda {
      where("total_mark >= #{CUTOFF_CERTIFICATE}")
    }
  end
end
