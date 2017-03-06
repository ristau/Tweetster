# Project 4 - *MyTwitter*

**MyTwitter** is a basic twitter app to read and compose tweets the Twitter API(https://apps.twitter.com/).

Time spent: **24** hours spent in total

## User Stories

The following **required** functionality is completed:

- [X] User can sign in using OAuth login flow
- [X] User can view last 20 tweets from their home timeline
- [X] The current signed in user will be persisted across restarts
- [X] In the home timeline, user can view tweet with the user profile picture, username, tweet text, and timestamp.
- [X] Retweeting and favoriting should increment the retweet and favorite count.

The following **optional** features are implemented:

- [X] User can load more tweets once they reach the bottom of the feed using infinite loading similar to the actual Twitter client 
- [X] User should be able to unretweet and unfavorite and should decrement the retweet and favorite count. 
- [X] User can pull to refresh. 

Partially implemented all the optionals. Can favorite and unfavorite, with incrementing and decrementing the correct fav count.
Pull to refresh and infinite loading are implemented, but create limit blocks.  

The following **additional** features are implemented:

- [X] Dates & Timestamp customized based on if tweet was sent less than an hour ago (displays minutes ago) or within the last 24 hours (displays hours ago)
- [X] Implemented custom logout button with title positioned via customizedoffsets under the image 
- [X] Implemented launch screen and app icons

Please list two areas of the assignment you'd like to **discuss further with your peers** during the next class (examples include better ways to implement something, how to extend your app in certain ways, etc):

1. Favorite count requires getting the original tweetID, where as retweet does not require this.  
2. Infinite scrolling and pull to refresh are based on the parameters "since_id" and "max_id" in the Twitter Client.  This seemed to work more smoothly compared to using an offset variable.  

## Video Walkthrough 

Here's a walkthrough of implemented user stories:

<img src='http://i.imgur.com/7toaRr4.gif' title='Video Walkthrough' width='' alt='Video Walkthrough' />

GIF created with LiceCap (http://www.cockos.com/licecap/).

## Notes
Challenges encountered while building the app: Unretweeting as outlined in Step 2 the Codepath guides did not function properly (api call was not recognized when I passed "include_my_retweet" as true, however, I was able to properly perform an unretweet using the path for "unretweet" in the Twitter API.   


## License

    Copyright 2017 Barbara Ristau

    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
    
   

##Project 5 - *Twitter Part 2*

Time spent: **28** hours spent in total

## User Stories

The following **required** functionality is completed:

- [X] Tweet Details Page: User can tap on a tweet to view it, with controls to retweet, favorite, and reply.
- [X] Profile page:
   - [X] Contains the user header view
   - [X] Contains a section with the users basic stats: # tweets, # following, # followers
- [X] Home Timeline: Tapping on a user image should bring up that user's profile page
- [X] Compose Page: User can compose a new tweet by tapping on a compose button.

The following **optional** features are implemented:

- [X] When composing, you should have a countdown for the tweet limit.
- [X] After creating a new tweet, a user should be able to view it in the timeline immediately without refetching the timeline from the network.
- [X] Profile Page
   - [ ] Implement the paging view for the user description.
   - [ ] As the paging view moves, increase the opacity of the background screen. See the actual Twitter app for this effect
   - [X] Pulling down the profile page should blur and resize the header image (partially implemented)
- [ ] Account switching
   - [ ] Long press on tab bar to bring up Account view with animation
   - [ ] Tap account to switch to
   - [ ] Include a plus button to Add an Account
   - [ ] Swipe to delete an account

The following **additional** features are implemented:

- [X]  User can reply to tweets
- [X]  Animation added to reply button when being selected 
- [X]  In addition to countdown, character limit is programmatically implemented
- [X]  User can see a tweet was retweeted or liked after restarting the app
- [X]  Customized NavBar in Profile Cell (transparent, using profile banner as background image)
- [X]  Implemented scrollview for displaying profice vc custom nav bar based on scrolling offset



Please list two areas of the assignment you'd like to **discuss further with your peers** during the next class (examples include better ways to implement something, how to extend your app in certain ways, etc):

1. Implement unwind segue when traversing back after a segue as a way of passing data 
2. Core Animation: I'd like to rework the image resizing and blur, not displaying exactly as I would like 

## Video Walkthrough 

Here's a walkthrough of implemented user stories:

<img src='http://i.imgur.com/JGpIoCX.gif' title='Video Walkthrough' width='' alt='Video Walkthrough' />

GIF created with [LiceCap](http://www.cockos.com/licecap/).

## Notes

Describe any challenges encountered while building the app: Building transitions

## License

    Copyright 2017  Barbara Ristau 
    
    Licensed under the Apache License, Version 2.0 (the "License");
    you may not use this file except in compliance with the License.
    You may obtain a copy of the License at

        http://www.apache.org/licenses/LICENSE-2.0

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
    See the License for the specific language governing permissions and
    limitations under the License.
