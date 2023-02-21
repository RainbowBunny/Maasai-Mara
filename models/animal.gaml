/**
* Name: animal
* Based on the internal empty template. 
* Author: user
* Tags: 
*/


model animal

/* Insert your model definition here */

global {
	float worldDimension <- 10.0;
	geometry shape <- square(worldDimension);
	
	int numberOfSpecies <- 5;
	int numberOfInitialSpecies <- 15;
	
	list<int> occ;
	list<wildLifeAnimal> uniqueType; 
	
	init {
		loop i from: 0 to: numberOfSpecies - 1 {
			add i to: occ;
			create wildLifeAnimal number: 1 returns: temp;
			temp[0].id <- i;
			temp[0].power <- rnd(0, 100000);
			temp[0].carnivore <- flip(1.0);
			temp[0].rarity <- rnd(0, 200);
			temp[0].distanceToIntercept <- rnd(5.0, 30.0);
			
			temp[0].r <- rnd(0, 255);
			temp[0].b <- rnd(0, 255);
			temp[0].g <- rnd(0, 255);
			
			add temp[0] to: uniqueType;
		}
		
		loop i from: 0 to: numberOfSpecies - 1 {
			create wildLifeAnimal number: numberOfInitialSpecies - 1 returns: arr;
			loop j from: 0 to: length(arr) - 1 {
				arr[j].id <- uniqueType[i].id;
				arr[j].power <- uniqueType[i].power;
				arr[j].carnivore <- uniqueType[i].carnivore;
			}
		}	
	}
}

species animal skills: [moving] {
	init {
		speed <- 5#m;
	}	
}

species wildLifeAnimal parent: animal {
	int power;
	int id;
	int rarity;
	bool carnivore;
	bool died;
	float distanceToIntercept;
	
	wildLifeAnimal target;
	
	int r;
	int b;
	int g;
	
	init {
		speed <- 5#m;
	}
	
	reflex alive {
		if (died) {
			write self;
			write "An animal has died!";
			do die;
		}
	}
	
	reflex move {
		if (!carnivore) {
			do wander amplitude: 50.0;		
		} else {
			target <- nil;
			list<wildLifeAnimal> inRange <- wildLifeAnimal at_distance(distanceToIntercept);
			loop i from: 0 to: min([5, length(inRange) - 1]) step: 1 {
				if (inRange[i].power < power) {
					target <- inRange[i];
					break;
				}
			}
			
			if (target != nil) {	
				do goto target: target;
				if (target != nil) {
					if (distance_to(self, target) <= 15#m) {
						bool win <- flip(1 - (0.95^(power - target.power)) / 2.0);
						if (win = true) {
							target.died <- true;
						}
					}
				}
				
			} else {
				do wander amplitude: 50.0;
			}
		}
	}
	
	aspect default {
		draw circle(1) color: rgb(r, b, g) border: #black;
		if (target != nil) {
			draw polyline([self.location, target.location]) color: #red;
		}
	}	
}


experiment test type: gui {
	output {
		display test {
			species wildLifeAnimal aspect: default;
			graphics test_graphics {

			}
		}
	}
}