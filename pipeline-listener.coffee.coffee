# Description:
#   Route direct messages from Jenkins SendSlack plugin to specified update rooms
#
# Commands:
#   hubot do stuff 
#
# Authors:
#   Ryan Willger


{WebClient} = require "@slack/client"

module.exports = (robot) ->
  web = new WebClient robot.adapter.options.token

  robot.hear /test/i, (res) ->
    web.api.test()
      .then () -> res.send "Your connection to the Slack API is working!"

  # When the script starts up, there is no notification room
  notification_room = undefined

  # Immediately, a request is made to the Slack Web API to translate a default channel name into an ID
  default_channel_name = "general"
  web.channels.list()
    .then (api_response) ->
      # List is searched for the channel with the right name, and the notification_room is updated
      room = api_response.channels.find (channel) -> channel.name is default_channel_name
      notification_room = room.id if room?

    # NOTE: for workspaces with a large number of channels, this result in a timeout error. Use pagination.
    .catch (error) -> robot.logger.error error.message

  #listens to direct messages OR in chat rooms
  robot.hear /badger/i, (res) ->
    if res.message.thread_ts?
      # The incoming message was inside a thread, responding normally will continue the thread
      res.send "Did someone say BADGER?"
    else
      # The incoming message was not inside a thread, so lets respond by creating a new thread
      res.message.thread_ts = res.message.rawMessage.ts
      res.send "Yes, more badgers please!"
  
  #listens only to direct messages
  robot.respond /golf/i, (res) ->
    robot.logger.debug "Received message #{res.message.text}"
    res.send "Yes, more golfs please!"

   robot.hear /UPDATE:(.*) J:(.*) MSG:(.*)/i, (res) ->

    #@#{res.message.user.id}
    roomID = "<<Slack Room ID>>"
    robot.messageRoom(roomID, "#{res.match[1]} > #{res.match[2]} > #{res.match[3]}" );

  robot.respond /turtle/i, (res) ->
    msgData = {
        "text": "required text"
    }

    # post the message
    web.chat.postMessage("C3YD4G97Y", msgData);

