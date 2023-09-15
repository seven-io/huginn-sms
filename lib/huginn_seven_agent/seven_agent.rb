require 'net/http'

module Agents
  class SevenAgent < Agent
    no_bulk_receive!
    cannot_create_events!
    cannot_be_scheduled!
    description <<-MD
      Agent for sending SMS from Huginn via seven.io.

      Get an API key at [seven](https://www.seven.io) and you are ready to start sending!

      Options:
      * `text` - The message you want to send (required)
      * `to` - recipient(s) separated by comma - phone number(s) or contact(s) (required)

      * `from` - Sender number. *Allowed value: A string of 11 alphanumeric or 16 numeric characters*
      * `debug` - If activated no SMS will be sent or calculated *Allowed values: 0, 1*
      * `delay` - Date/time for time-delayed SMS: *Allowed values: A UNIX timestamp or date with format yyyy-mm-dd hh:ii*
      * `no_reload` - Switch off reload lock. This lock prevents the sending of the same SMS (text, type and recipient alike) within 180 seconds *Allowed values: 0, 1*
      * `unicode` - For Cyrillic, Arabic etc characters. SMS length is then reduced to 70 characters. The API recognizes the coding automatically; this parameter enforces it *Allowed values: 0, 1*
      * `flash` - Send SMS as Flash SMS. These are displayed directly in the receiver’s display *Allowed values: 0, 1*
      * `udh` - Individual User Data Header of the SMS. If specified and parameter text contains hexcode, message gets sent as 8-bit binary
      * `utf8` - Forces the detection as a UTF8 character set and overrides automatic recognition of the API *Allowed values: 0, 1*
      * `ttl` - Specifies the validity period of the SMS in milliseconds *Allowed values: integer between 300000 and 86400000*
      * `details` - Shows numerous details to the sent SMS. Handy for debugging *Allowed values: 0, 1*
      * `return_msg_id` - If this parameter is set, the ID of the SMS is output in the second line after the status code *Allowed values: 0, 1*
      * `label` - Custom label for whatever use. *Allowed characters*: a-z, A-Z, 0-9, .-_@
      * `json` - The output is more detailed in JSON format *Allowed values: 0, 1*
      * `performance_tracking` - Enable Performance Tracking for URLs found in the message text *Allowed values: 0, 1*
      * `foreign_id` - Custom tag to return in DLR callbacks etc. Max. 64 chars. *Allowed characters: a-z, A-Z, 0-9, .-_@*
    MD

    def default_options
      {
          'api_key' => 'xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx',
          'from' => 'Huginn',
          'text' => 'Hope to see you again soon!',
          'to' => '+4900000000000',
          'debug' => 0,
          'delay' => nil,
          'no_reload' => nil,
          'unicode' => 0,
          'flash' => 0,
          'udh' => nil,
          'utf8' => 0,
          'ttl' => nil,
          'details' => 0,
          'return_msg_id' => 0,
          'label' => nil,
          'json' => 0,
          'performance_tracking' => 0,
          'foreign_id' => nil,
      }
    end

    def validate_options
      unless options['api_key'].present?
        errors.add(:base, '`api_key` is required.')
      end

      unless interpolated['text'].present?
        errors.add(:base, '`text` is required.')
      end

      unless interpolated['to'].present?
        errors.add(:base, '`to` is required.')
      end
    end

    def working?
      interpolated['api_key'].present? && !recent_error_logs?
    end

    def receive(incoming_events)
      incoming_events.each do |event|
        interpolate_with event do
          send_sms(interpolated)
        end
      end
    end

    def send_sms(payload)
      fd = default_options
      fd.delete('api_key')
      fd.each { |k, v| fd[k] = payload[k] }

      body = HTTParty.post('https://gateway.seven.io/api/sms',
                           :body => fd, :headers => {'Authorization' => "Basic #{payload['api_key']}"})

      if !body.is_a?(Hash)
        begin
          body = JSON.parse(body)
        rescue JSON::ParserError => e
          # Ignored
        end
      end

      code = Hash === body ? body['success'] : "#{body}".split(/\n+/)[0]
      code = code.to_i

      if [100, 101].include? code
        log body
      elsif 900 === code
        raise StandardError, "SEVEN_AUTH_ERROR: #{body}"
      else
        raise StandardError, "SEVEN_DISPATCH_ERROR: #{body}"
      end

      body
    end
  end
end
