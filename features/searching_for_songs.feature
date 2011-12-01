Feature: Searching for songs
  In order to play songs
  As a chat room participant
  I want to search and queue songs

Scenario: default song search

Given The following songs match the rdio search "take five":
 | index |song | artist | album |
 | 0 | Take Five | Dave Brubeck Quartet | Time Out|
 | 1 | Take Five Fingers | Brave Dubeck Fartet | Rhyme Out|

When I type the following into the chat room:
 |@dj find take five|

Then I should see the following song titles in the search result:
 | index | song |
 | 0     | Take Five |
 | 1     | Take Five Fingers |

When I type the following into the chat room:
 |@dj play 1|

Then the song "Take Five" should be queued


