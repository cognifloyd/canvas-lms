class Quizzes::QuizQuestionRegrade < ActiveRecord::Base
  self.table_name = 'quiz_question_regrades' unless CANVAS_RAILS2

  attr_accessible :quiz_question_id, :quiz_regrade_id, :regrade_option
  belongs_to :quiz_question, :class_name => 'Quizzes::QuizQuestion'
  belongs_to :quiz_regrade, class_name: 'Quizzes::QuizRegrade'

  validates_presence_of :quiz_question_id
  validates_presence_of :quiz_regrade_id

  delegate :question_data, to: :quiz_question
end
