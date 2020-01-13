namespace :images do
  desc "Deletes images that are older than 5 days"
  task delete_old_entries: :environment do
    images = Image.where(['created_at < ?', 5.days.ago]).where.not(filename: 'test.jpg')
    images.each do |image|
        path = Rails.root.join('public', 'uploads', image.filename)
        File.delete(path) if File.exist?(path)
        puts "#{Time.now} #{image.filename}"
        image.delete
    end
  end

end
