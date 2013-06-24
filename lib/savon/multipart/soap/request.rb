module Savon
  module SOAP
    class Request

    private

      def configure(http)
        http.url = soap.endpoint
        if soap.has_parts? # do multipart stuff if soap has parts
          request_message = soap.request_message
          # takes relevant http headers from the "Mail" message and makes
          # them Net::HTTP compatible
          request_message.header.fields.each do |field|
            # the mail gem clobbers the text encoding and sets its own (utf-8 in our case)
            # remove the mail text encoding here
            # http.headers[field.name] = field.to_s
            http.headers[field.name] = field.to_s.split(';').delete_if {|s| s =~ /charset/}.join(';')
          end
          #request.headers["Content-Type"] << %|; start="<savon_soap_xml_part>"|
          request_message.body.set_sort_order soap.parts_sort_order if soap.parts_sort_order && soap.parts_sort_order.any?
          http.body = request_message.body.encoded
        else
          http.body = soap.to_xml
        end
        http.headers["Content-Type"] ||= CONTENT_TYPE[soap.version]
        http.headers["Content-Length"] = http.body.bytesize.to_s
        http
      end

    end
  end
end
