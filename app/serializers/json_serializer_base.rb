class JsonSerializerBase
  include ActiveModel::Serializers::JSON

  def initialize(attrs)
    attrs.each do |key, value|
      self.instance_variable_set("@#{key}", value)
    end
  end
end
