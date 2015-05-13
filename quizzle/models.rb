class Question < ActiveRecord::Base
  has_one :answer, :dependent => :delete
  has_many :distractors, :dependent => :delete_all
  before_save :update_merged_text
  accepts_nested_attributes_for :answer, :distractors, :allow_destroy => true

  def responses(random: false)
    res = [answer] + distractors
    if random
      res.shuffle!
    else
      res = res.sort_by(&:value)
    end
    res.map{|o| {value: o.value, correct: o.is_a?(Answer)}}
  end

  def update_merged_text
    self.merged_text = "#{value}\v#{answer.value}\v#{distractors.pluck(:value).join("\v")}"
  end

  def as_json(options=nil)
    super(:methods => [:responses], :except => [:updated_at, :created_at, :merged_text])
  end

end

class Answer < ActiveRecord::Base
  belongs_to :question
end

class Distractor < ActiveRecord::Base
  belongs_to :question
end
