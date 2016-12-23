class Result < ApplicationRecord

    validates :value, presence: true
    has_many :user, :through => :user_results

end
