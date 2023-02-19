/**
* Name: Object
* Based on the internal empty template. 
* Author: user
* Tags: 
*/


model Object

/* Insert your model definition here */

global {
	float step <- 1#second;
	
	int localPopulation <- 50;
	float safetyRate <- 0.95 min: 0.0 max: 1.0;
	float lifeQuality <- 1.3;
	float averageIncome <- 100.0;
	
	action setOwner(livestock ownedLivestock, localPeople newOwner) {
		ownedLivestock.owner <- newOwner;
	}
	
	init {
		create localPeople number: localPopulation;
	}
}

species localPeople skills: [moving] {
	int numberOfOwnedLivestock;
	list<livestock> owned;
	
	init {
		speed <- 5#m;
		numberOfOwnedLivestock <- rnd(3, 10);
		loop i from: 1 to: numberOfOwnedLivestock {
			livestock nw;
			do setOwnership(nw);
			add nw to: owned;
		}  		
	}
	
	reflex move {
		do wander amplitude: 50.0;
	}
	
	action setOwnership(livestock ownedLivestock){
		ownedLivestock.owner <- self;
	}
	
	aspect default {
		draw circle(1) color: #blue border: #black;
	}
}

species animal skills: [moving] {
	init {
		speed <- 5#m;
	}	
}

species wildLifeAnimal parent: animal {
	
}

species livestock parent: animal {
	localPeople owner;
	
	init {
		speed <- 5#m;
	}
	
	reflex move {
		do wander amplitude: 2.0;
		do goto speed: 2#m target: owner;
	}
	
	aspect default {
		draw circle(1) color: #red border: #black;
	}
}



experiment test type: gui {
	output {
		display test {
			species localPeople aspect: default; 
			species livestock aspect: default;
		}
	}
}