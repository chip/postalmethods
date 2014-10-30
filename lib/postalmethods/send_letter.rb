#encoding: utf-8

module PostalMethods

  module SendLetter

    def send_letter(doc, description, work_mode = "")
      #raise PostalMethods::NoPreparationException unless self.prepared
      ## push a letter over the api

      #Encoding.default_external = Encoding::UTF_8
#[
    #[ 0] :send_letter,
    #[ 1] :send_letter_and_address,
    #[ 2] :get_letter_status,
    #[ 3] :get_letter_status_multiple,
    #[ 4] :get_letter_status_range,
    #[ 5] :get_letter_details,
    #[ 6] :get_pdf,
    #[ 7] :cancel_delivery,
    #[ 8] :send_letter_v2,
    #[ 9] :send_letter_and_address_v2,
    #[10] :send_postcard_and_address,
    #[11] :upload_file,
    #[12] :get_letter_details_v2,
    #[13] :get_letter_status_v2,
    #[14] :get_letter_status_v2_multiple,
    #[15] :get_letter_status_v2_range
#]

      self.document = doc
      require "pry"
      binding.pry

      puts client.operations

      ops = client.operation(:send_letter)
      #ops = client.operation(:send_letter_v2)

      xml = ops.build(
        message: {
          Username: self.username,
          Password: self.password,
          #api_key: ENV['POSTAL_METHODS_API_KEY'],
          FileExtension: self.document[:extension],
          FileBinaryData: self.document[:bytes],
          MyDescription: description,
          WorkMode: self.work_mode
        }
      ).pretty
      puts xml

      rv = ops.call
      puts rv
      #rv = client.call(:send_letter_v2,
        #message: {
          #Username: self.username,
          #Password: self.password,
          #api_key: ENV['POSTAL_METHODS_API_KEY'],
          #FileExtension: self.document[:extension],
          #FileBinaryData: self.document[:bytes],
          #MyDescription: description,
          #WorkMode: self.work_mode
        #}
      #)
      binding.pry

      #status_code = rv.sendLetterV2Result.to_i
      #status_code = rv.hash[:envelope][:body][:send_letter_v2_response][:send_letter_v2_result].to_i
      status_code = rv.hash[:envelope][:body][:send_letter_response][:send_letter_result].to_i

      binding.pry
      if status_code > 0
        return status_code
      elsif API_STATUS_CODES.has_key?(status_code)
        instance_eval("raise APIStatusCode#{status_code.to_s.gsub(/( |\-)/,'')}Exception")
      end
    end

    def send_letter_with_address(doc, description, address)
      raise PostalMethods::NoPreparationException unless self.prepared
      raise PostalMethods::AddressNotHashException unless (address.class == Hash)

      ## setup the document
      self.document = doc

      opts = {:Username => self.username, :Password => self.password, :api_key => ENV['POSTAL_METHODS_API_KEY'], :FileExtension => self.document[:extension],
                                  :FileBinaryData => self.document[:bytes], :MyDescription => description, :WorkMode => self.work_mode}

      opts.merge!(address)

      ## push a letter over the api
      rv = @rpc_driver.sendLetterAndAddressV2(opts)
      status_code = rv.sendLetterAndAddressV2Result.to_i

      if status_code > 0
        return status_code
      elsif API_STATUS_CODES.has_key?(status_code)
        instance_eval("raise APIStatusCode#{status_code.to_s.gsub(/( |\-)/,'')}Exception")
      end
    end

  end

end
