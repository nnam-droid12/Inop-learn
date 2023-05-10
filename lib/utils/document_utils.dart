class Document {
  String? doc_title;
  String? doc_url;
  String? doc_date;
  int? page_num;

  Document(this.doc_title, this.doc_url, this.doc_date, this.page_num);

  static List<Document> doc_list = [
    Document("The Imact of AI", "", "23-03-2018", 40),
     Document("The Imact of AI", "", "23-03-2018", 40),
      Document("The Imact of AI", "", "23-03-2018", 40),
       Document("The Imact of AI", "", "23-03-2018", 40),

  ];
}
