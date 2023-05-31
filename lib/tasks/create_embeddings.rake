namespace :pdf do
  desc "Creates embeddings from a PDF file"
  task :create_embeddings, [:file_path] => :environment do |task, args|
    raise "Missing file_path argument. Usage: rake pdf:create_embeddings['path/to/file/filename.pdf']" if args.file_path.blank?

    file_path = args.file_path

    OUTPUT_DIRECTORY = EmbeddingsGenerator::EMBEDDINGS_DIRECTORY
    embeddings_generator = EmbeddingsGenerator.new

    puts "Creating CSV file for page content in PDF"
    embeddings_generator.create_pages_csv(
      pdf_file_path: file_path,
      csv_file_name: 'pages.csv'
    )

    puts "File created. You can view it at #{OUTPUT_DIRECTORY}/pages.csv"
    puts
    puts

    puts "Creating CSV file embedding each page in PDF"
    embeddings_generator.create_embeddings_csv(
      pages_csv_file_path: "#{OUTPUT_DIRECTORY}/pages.csv",
      output_file_name: 'embeddings.csv'
    )

    puts "File created. You can view it at #{OUTPUT_DIRECTORY}/embeddings.csv"
  end
end
