# cinch-drewbot - a plugin for Cinch

## Description

This is a small plugin for the Cinch IRC bot framework that allows channel members to track the lines spoken by one member ("drew" in this case) and print them to the channel.

### Example Usage

```
<user> !drew
<bot> Some words by drew pulled from a Weechat log
<user> !drew query phrase
<bot> A quote from drew containing 'query phrase'
```

## Dependencies
* [Cinch](https://github.com/cinchrb/cinch) (`gem install cinch`)
* [Weechat](https://weechat.org/)

## Notes

As it is currently written, the script takes a standard .weechatlog as the corpus to draw from. It can conceivably accept logs from other irc clients, they just need to be in the format:

```
TIMESTAMP<tab>NICK<tab>MESSAGE
```
