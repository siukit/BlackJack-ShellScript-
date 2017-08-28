#!/bin/bash

#assign integer 1 to 52 to a deck array
function prepareDeck
{
	card=1
	while [ $card -le 52 ]
	do
		deck[$card]=$card
		card=$((card+1))
	done
}

#choose a random integer from 1 to 52, (if that integer is not a picked) assign it to the pickedCard variable,
#then assign -1 to the deck array's index value which means that index(card) is being picked
function pickCard
{	
	pickedCard=0
	#use the modular to get a random number from 1 to 52
	c=$(($RANDOM%52))
	#ensure the value was not being taking by using while loop
	while [ deck[$c] == -1 ]
	do
		c=$(($RANDOM%52))
	done
		
	pickedCard=$c
	#assign -1 to the index of the picked card on the deck array
	deck[$pickedCard]=-1;
}

#get the the suite and rank of the selected card and assign them to a variable called cardName
function showCard
{
	#take a card as argument
	card=$1
	suites=('Hearts' 'Clubs' 'Spades' 'Diamonds')
	ranks=(Ace 2 3 4 5 6 7 8 9 10 Jack Queen King)
	#get the suite of that card by deviding that card value by 13 (each deck has 52 cards and there are four suite)
	s=$(( $card / 13 ))
	#also get the rank of that card by getting the remainder of that card value devided by 13 (because there are 14 ranks in each suite)
   	r=$(( $card % 13))
	#take the selected index of the suite array (from the calculated value s) and assign it to suite variable
	suite=${suites[$s]}
	#take the selected index of the ranks array (from the calculated value r) and assign it to rank variable
	rank=${ranks[$r]}
	#take both rank and suite variables in the cardName string
	cardName="$rank of $suite"
	#assign 11 to rank if the original variable is Ace, and 10 if it was jack/queen/king
	case $rank in
		Ace)rank=11 ;;
		Jack|Queen|King) rank=10 ;;
	esac
		
}

#check if the player's card value is 11, if so it is an ace
function checkAce
{
	r=$1
	if [ "$r" -eq 11 ]; then
		#ask if the player want that ace to be 1 or 11, then assign new value to rank variable
		echo "You have got an Ace which can be counted as 1 or 11, please enter '1' or '11' to choose the desire value"
		read value
		if [ "$value" == 1 ]; then
			rank=1
		elif [ "$value" == 11 ]; then
			rank=11
		fi
	fi
}

#check if the dealer's card value is 11, if so assign boolean true to ace variable
function dealerCheckAce
{
	r=$1
	if [ "$r" -eq 11 ]; then
		ace=true
	fi
}


#main code that runs the game starts here
echo "Welcome to Blackjack"
prepareDeck
#create two arrays to store the dealer and player picked cards
#get the $pickedCard variables from the function pickCard and assign it the dealer/player card arrays
#when game starts, assign two cards to dealer and two cards to player
pickCard
dealerCard[1]=$pickedCard
pickCard
dealerCard[2]=$pickedCard
pickCard
playerCard[1]=$pickedCard
pickCard
playerCard[2]=$pickedCard

#put the two dealer cards to the function showCard in order to get the card names and card values
showCard dealerCard[1]
#display the first dealer card name 
echo "Dealer's first card is: $cardName"
echo "Dealer's second card is: faced down"
dealerCheckAce $rank
dealerCard1=$rank
#display the dealer first card's value
echo "Dealer's hand value is $dealerCard1 (Excluded the hole card)"
showCard dealerCard[2]
dealerCheckAce $rank
dealerCard2=$rank
#add up the values from both dealer's cards and store the total to dealerTotal variable
dealerTotal=$(($dealerCard1+$dealerCard2))
#if the dealer got an ace and the total are greater than 21
if [ "$ace"=true -a $dealerTotal -gt 21 ]; then
	dealerTotal=$(($dealerTotal-10))
	ace=false
fi


#put the two player cards to the function showCard in order to get the card names and card values
showCard playerCard[1]
echo "Your first card is: $cardName"
checkAce $rank
playerCard1=$rank

showCard playerCard[2]
echo "Your second card is: $cardName"
checkAce $rank
playerCard2=$rank
#add up the values from both player's cards and store the total to dealerTotal variable
playerTotal=$(($playerCard1+$playerCard2))
#display the player's cards total values
echo "Your hand value is $playerTotal"

#set the nextCard as 3 because two cards were picked for dealer/player
nextCard=3
#if the nextCard is less than 5, run this loop
while [ $nextCard -le 5 ]
do
	#all the if else statements below check if the dealer or player have busted,
	#or got blackjack, if those are the case then the game will be over
	#if not it will ask the player to choose Hit or Stick
	if [ $dealerTotal -gt 21 -a $playerTotal -lt 21 ]; then
		echo "Dealer busted! You win!"
		exit 0
	elif [ $dealerTotal -gt 21 -a $playerTotal -gt 21 ]; then
		echo "Unfortunately, You and the dealer both busted!!"
		exit 0
	elif [ $playerTotal -gt 21 ]; then
		echo "You busted!"
		exit 0
	elif [ $dealerTotal -eq 21 -a $playerTotal -eq 21 ]; then
		echo "Both the dealer and you have pulled a blackjack, it's a tie!"
		exit 0
	elif [ $dealerTotal -eq 21 ]; then
		echo "Dealer pulled a blackjack, you lose!"
		exit 0
	elif [ $playerTotal -eq 21 ]; then
		echo "You have pulled a blackjack, you win!"
		exit 0
	else
		echo "Would you like to (H)it or (S)tick?"
	fi


	read choice
	#if player Hit and dealer hand values is less than 17, both the player and the dealer pick a card
	#new card points will be added to the dealer's and player's total
	if [ "$choice" = 'h' -a $dealerTotal -lt 17 ]; then
		pickCard
		dealerCard[$nextCard]=$pickedCard
		showCard dealerCard[$nextCard]
		dealerCheckAce $rank
		echo "Dealer picks a card..."
		echo "Dealer's got: $cardName"
		dealerTotal=$(($rank+$dealerTotal))
		if [ "$ace"=true -a $dealerTotal -gt 21 ]; then
			dealerTotal=$(($dealerTotal-10))
			ace=false
		fi
		echo "Dealer's hand value is $dealerTotal"
		pickCard
		playerCard[$nextCard]=$pickedCard
		showCard playerCard[$nextCard]
		dealerCheckAce $rank
		echo "You pick a card..."
		echo "You've got: $cardName"
		checkAce $rank
		playerTotal=$(($rank+$playerTotal))
		echo "Your hand value is $playerTotal"
	#if the player decided to stick and dealer's total is less than 17,
	#dealer will continue to pick card until the total is more than 17
	elif [ "$choice" = "s" -a $dealerTotal -lt 17 ]; then
		while [ $dealerTotal -lt 17 ]
		do
			pickCard
			dealerCard[$nextCard]=$pickedCard
			showCard dealerCard[$nextCard]
			dealerCheckAce $rank
			echo "Dealer picks a card..."
			echo "Dealer's got: $cardName"
			dealerTotal=$(($rank+$dealerTotal))
			if [ "$ace"=true -a $dealerTotal -gt 21 ]; then
				dealerTotal=$(($dealerTotal-10))
				ace=false
			fi
			echo "Dealer's hand value is $dealerTotal"
		done
		#if dealer busted
		if [ $dealerTotal -gt 21 ]; then
			echo "Dealer busted, you win!"
			exit 0
		elif [ $dealerTotal -eq 21 ]; then
			echo "Dealer pulled a blackjack, you lose!"
		#if dealer's total points is higher than player
		elif [ $dealerTotal -gt $playerTotal ]; then
			echo "Dealer has higher points than you, you lose!"
			exit 0
		#otherwise player has higher points
		else
			echo "You have higher point than dealer, you win!"
			exit 0
		fi
	#if player decided to hit but dealer's total is higher than 17,
	#only the player will pick a card
	elif [ "$choice" = "h" ]; then
		pickCard
		playerCard[$nextCard]=$pickedCard
		showCard playerCard[$nextCard]
		echo "You pick a card..."
		echo "You've got: $cardName"
		checkAce $rank
		playerTotal=$(($rank+$playerTotal))
		echo "Your hand value is $playerTotal"
		echo "Dealer's hand value is $dealerTotal"
	else
		#if player chose to stick and dealer's hand value is higher than 17
		#both the dealer and player will stop picking card
		#and the side who has the higher points will win the game
		if [ $dealerTotal -gt $playerTotal ]; then
			echo "Dealer has higher points than you, you lose!"
			exit 0
		else
			echo "You have higher point than dealer, you win!"
			exit 0
		fi
	fi

	nextCard=$((nextCard+1))
done

#if the player has picked more than 5 cards and still not busted yet, he will automatically win the game
echo "You have picked more than five cards and not busted yet! You win!"



















