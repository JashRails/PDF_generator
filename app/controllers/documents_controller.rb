require 'fastimage'
require 'aws-sdk'

class DocumentsController < ApplicationController

  before_action :authenticate_user!
  before_action :set_document, only: [:show]

  def index # show all templates
    @documents = Document.where(user_id: current_user.id).order("CREATED_AT DESC")
  end

  def new
    @document = Document.new
  end
  
  def create
    new_document = Document.new(document_params)
    new_document.user_id = current_user.id

    new_document.save

    puts "--- Creating PDF"
    
    # Create PDF
    Prawn::Document.generate("public/pdfs/#{new_document.id}_#{new_document.customer_name}.pdf", :margin => 0) do
      # first page
      font_families.update("Calibri" => {
        :normal => "app/assets/fonts/Calibri.ttf"
      })

      font_size 16
      font "Calibri"
      fill_color "ffffff"

      # image "#{Rails.root}/app/assets/images/1.png", :at => [0, 792], :width => 612
      image "app/assets/images/1.png", :at => [0, 792], :width => 612
      image open("#{new_document.first_image.url}"), :at => [0, 570], :width => 464, :height => 317

      draw_text "TheRTAStore.com Room Design", :at => [20, 752], :size => 30
      draw_text "Designed For: #{new_document.customer_name}", :at => [20, 724]
      draw_text "Designed By: #{new_document.designer_name}", :at => [20, 702]
      draw_text "Finish Name: #{new_document.finish_name}", :at => [20, 680]
      draw_text "Designer Phone: #{new_document.designer_phone}", :at => [20, 658]
      draw_text "Office Phone: #{new_document.office_phone}", :at => [20, 636]
      draw_text "Designer Email: #{new_document.designer_email}", :at => [20, 614]
      draw_text "Date: #{new_document.date}", :at => [20, 592]

      # 2 ~ Custom pages
      if new_document.images.present?
        new_document.images.each do |img|
          start_new_page

          # header - 7c131d
          fill_color "7c131d"
          fill_rectangle [0, 792], 612, 73

          # footer - 185471
          fill_color "185471"
          fill_rectangle [0, 53], 612, 53

          # restore color
          fill_color "ffffff"

          # fill image
          arr = FastImage.size("#{img.url}")
          aspect_ratio = [612.0 / arr[0], 666.0 / arr[1]].min
          width = arr[0] * aspect_ratio
          height = arr[1] * aspect_ratio

          image open("#{img.url}"), :at => [(612.0 - width) / 2, 719 - (666.0 - height) / 2], :width => width, :height => height
        end
      end

      # 3 ~ 12 pages
      for i in 3..12
        start_new_page
        image "app/assets/images/#{i}.png", :at => [0, 792], :width => 612
      end
      # start_new_page
      # last page
      start_new_page
      image "app/assets/images/13.png", :at => [0, 792], :width => 612
      image open("#{new_document.last_image.url}"), :at => [0, 720], :width => 612, :height => 373
    end
    puts "--- Ended"
    # image "#{Prawn::DATADIR}/images/pigs.jpg", :fit => [size, size]

    # Uploading to S3
    begin
      file_name = "#{new_document.id}_#{new_document.customer_name}.pdf"

      s3 = Aws::S3::Resource.new(region: ENV['AWS_REGION'])
      obj = s3.bucket(ENV['S3_PDF_BUCKET_NAME']).object(file_name)
      obj.upload_file("public/pdfs/#{new_document.id}_#{new_document.customer_name}.pdf", acl:'public-read')
      
      # Remove local file
      File.delete("public/pdfs/#{new_document.id}_#{new_document.customer_name}.pdf")
    rescue Aws::S3::Errors::ServiceError
    end

    redirect_to documents_path
  end

  def show
    redirect_to "https://s3.us-east-2.amazonaws.com/#{ENV['S3_PDF_BUCKET_NAME']}/#{@document.id}_#{@document.customer_name}.pdf"
  end

  private

  def document_params
    params.require(:document).permit(:customer_name, :designer_name, :finish_name, :designer_phone, :office_phone, :designer_email, :date, :first_image, :last_image, {images: []})
  end

  def set_document
    @document = Document.find(params[:id])
  end
end
