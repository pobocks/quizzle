class Question < ActiveRecord::Base
  has_one :answer, :dependent => :delete
  has_many :distractors, :dependent => :delete_all

  def responses(random: true)
    res = [answer] + distractors
    res.shuffle! if random
    res.map{|o| {value: o.value, correct: o.is_a?(Answer)}}
  end

  def as_json(options=nil)
    super(:methods => [:responses])
  end

end

class Answer < ActiveRecord::Base
  belongs_to :question
end

class Distractor < ActiveRecord::Base
  belongs_to :question
end
