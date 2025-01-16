class DryInteractor
  include Dry::Monads::Do
  include Dry::Monads::Result::Mixin
  include Dry::Monads::Maybe::Mixin
  extend Dry::Initializer

  class << self
    ruby2_keywords def call(*args)
      new(*args).call
    end
  end
end
