class Resource < ActiveRecord::Base
  belongs_to :node
  attr_accessible :count, :name, :url

  validates :name, :presence => true, :uniqueness => true
  validates :count, :presence => true
  validates :url, :presence => true, :uniqueness => true

  def initialize_with_defaults(attrs = nil, &block)
    initialize_without_defaults(attrs) do
      setter = lambda { |key, value| self.send("#{key.to_s}=", value) unless !attrs.nil? && attrs.keys.map(&:to_s).include?(key.to_s) }
      setter.call('count', 0)
      yield self if block_given?
    end
  end
  alias_method_chain :initialize, :defaults
end
