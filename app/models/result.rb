class Result < ApplicationRecord

    has_many :user, :through => :user_results



end
