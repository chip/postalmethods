module PostalMethods
  module DocumentProcessor

    require "pry"
   def document=(doc)
    binding.pry
     unless doc.class == File
       doc = File.open(doc, "rb")
     end

     self.to_send = {} if self.to_send.nil?

     self.to_send[:extension] = doc.path.to_s.split('.').last
     self.to_send[:bytes] = doc.read
     self.to_send[:name] = File.basename(doc.path)
     self.to_send[:file_obj] = doc
   end

   def document?
     true unless self.to_send.nil?
   end

   def document
     self.to_send
   end
  end
end
