class Document < ApplicationRecord
  mount_uploader :first_image, ImageUploader
  mount_uploader :last_image, ImageUploader
  mount_uploaders :images, ImageUploader

  belongs_to :user

end
