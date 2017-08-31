# frozen_string_literal: true

# Monitoring class for Karafka process
class KarafkaMonitor < Karafka::Monitor
  # Reports problems to Errbit
  # @param caller_class [Class] class in which error happened
  # @param e [Exception] exception that happened
  def notice_error(caller_class, e)
    super # Super will log into file as well
    Airbrake.notify(e)
  end
end
