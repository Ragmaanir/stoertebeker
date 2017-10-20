# Crystals HTTP::Server does not expose the host. This patch adds the getter for it.
class HTTP::Server
  getter host : String
end
