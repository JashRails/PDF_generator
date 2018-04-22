module ApplicationHelper

  def s3_url(doc)
    "https://s3.us-east-2.amazonaws.com/#{ENV['S3_PDF_BUCKET_NAME']}/#{doc.id}_#{doc.customer_name}.pdf"
  end

end
