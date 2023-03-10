class EventSerializer < ActiveModel::Serializer
  attributes :id, :name, :address, :city, :state, :zipcode, :time, :date, :description, :latitude, :longitude
  has_one :user
  has_many :attending_users
  has_many :comments
end
