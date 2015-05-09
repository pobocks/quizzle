class Question < ActiveRecord::Base
  has_one :answer, :dependent => :delete
  has_many :distractors, :dependent => :delete_all

  def options(random: true)
    res = [answer] + distractors
    res.shuffle! if random
  end
end

class Answer < ActiveRecord::Base
  belongs_to :question
end

class Distractor < ActiveRecord::Base
  belongs_to :question
end
