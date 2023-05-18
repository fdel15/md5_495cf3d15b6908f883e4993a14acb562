Input: PDF
Output: embeddings.csv, pages.csv

Requirements:

- Use OpeanAI API

  - COMPLETETIONS_MODEL = "text-embedding-ada-002"
    - tokenizer = "cl100k_base"
    - 8191 max input tokens
    - ~3000 pages per dollar
    - output dimensions: 1536
  - Need to extract the text from a pdf
    - Need a way to count tokens so we can limit input based on max
  - We want to write a CSV file that:
    - has page number
    - text from page
    - token count
  - Filter content that is greater than max input tokens

  - Create embeddings.csv that does:
    - columns:
      - title
      - 1536 vector columns
    - For each row in CSV that contains content
      - title = page_number
      - get embedding from OpenAI
      -
