/**
* Name: environment
* Based on the internal empty template. 
* Author: user
* Tags: 
*/


model environment

/* Insert your model definition here */

global {
	float CIRCLE_SIZE <- 9;
	float RANGE <- 5#m;
	int RECOVER <- 200;
	int STEP <- 220;
	int TIME_RANGE <- 5;
	int AVERAGE_BUDGET <- 900;
	float LIVESTOCK <- 0.5;

	int numberOfLocalPeople <- 200;
	int numberOfVisitors <- 200;
	
	int numberOfSpecies <- 0;
	int numberOfInitialSpecies <- 200;
	
	list<wildLifeAnimal> uniqueType; 
	
	float worldSize <- 4000.0;
	
	
	geometry shape <- square(worldSize);

	list<graph> livingArea;

	graph natureNetwork;	
	graph roadNetwork;
	graph huntingArea;
	
	file riverFile <- file("C:/Users/user/Documents/Maasai-Mara/MapData/River.shp");
	file regionFile <- file("C:/Users/user/Documents/Maasai-Mara/MapData/ares.shp");
	file roadFile <- file("C:/Users/user/Documents/Maasai-Mara/MapData/road.shp");
	
	file popLessThan15 <- file("C:/Users/user/Documents/Maasai-Mara/MapData/lessthan15.shp");
	file pop15_49 <- file("C:/Users/user/Documents/Maasai-Mara/MapData/15_49.shp");
	file pop50_99 <- file("C:/Users/user/Documents/Maasai-Mara/MapData/50_99.shp");
	file pop100_249 <- file("C:/Users/user/Documents/Maasai-Mara/MapData/100_249.shp");
	file pop250_499 <- file("C:/Users/user/Documents/Maasai-Mara/MapData/250_499.shp");
	file pop500_9999 <- file("C:/Users/user/Documents/Maasai-Mara/MapData/500_9999.shp");
	
	file immigrateFile <- file("C:/Users/user/Documents/Maasai-Mara/MapData/imigateRegion.shp");
	file outsideFile <- file("C:/Users/user/Documents/Maasai-Mara/MapData/outside.shp");
	
	action createArea(file fileName, rgb areaColor, int density, int numberOfDifferentAnimal) {
		numberOfSpecies <- numberOfSpecies + numberOfDifferentAnimal;
		create distributedArea from: fileName returns: currentArea;
				
		
		
		loop i from: 0 to: length(currentArea) - 1 {
			currentArea[i].color <- areaColor;
			currentArea[i].peopleDensity <- density;
			currentArea[i].numberOfDifferentAnimal <- numberOfDifferentAnimal;
			
			int tomato <- length(livingArea);
			graph newArea <- as_edge_graph(currentArea[i]);
			add newArea to: livingArea;
			
			create localPeople number: currentArea[i].peopleDensity returns: localPeopleInArea;
			loop j from: 0 to: length(localPeopleInArea) - 1 {
				localPeopleInArea[j].location <- any_location_in(currentArea[i]);
				localPeopleInArea[j].spawningArea <- tomato; 
			}
			
			loop j from: 0 to: length(numberOfDifferentAnimal) - 1{
				int numberOfThisKind <- int(rnd(10, 20));
				
				create wildLifeAnimal number: numberOfThisKind returns: leader;
				
				leader[0].id <- length(uniqueType);
				leader[0].spawningArea <- tomato;
				leader[0].rarity <- rnd(0, 200);
				leader[0].reproduction <- 4000;
				leader[0].location <- any_location_in(currentArea[i]);
				
				add leader[0] to: uniqueType;

				loop k from: 1 to: numberOfThisKind - 1 {
					leader[k].id <- leader[0].id;
					leader[k].spawningArea <- leader[0].spawningArea;
					leader[k].rarity <- leader[0].rarity;
					leader[k].reproduction <- leader[0].reproduction;
					leader[k].location <- any_location_in(currentArea[i]);
				}
			}
		}
	}
	
	list<int> RList;
	list<int> WList;
	list<float> localIncomeList;
	list<float> govIncomeList;
	
	
	int Sum;
	int month;	

	int R;
	int W;
	
	float localIncome <- 0.0;
	float govIncome <- 0.0;
	
	action mod(int a, int b) {
		return a - b * int(a / b);
	}
	
	reflex {
		month <- month + 1;
		localIncome <- localIncome + length(localPeople) * 750 * LIVESTOCK * 1.5 / 1000;
		
		create visitor number: 15;
	}	
	
	
	reflex {
		R <- 0;
		loop i from: 0 to: length(nature) - 1 {
			R <- R + nature[i].power;
		}

		W <- 0;
		list<int> count;
		loop i from: 0 to: length(uniqueType) {
			add 0 to: count;
		}	
		
		int uniqueAnimalAlive <- 0;
		loop i from: 0 to: length(wildLifeAnimal) - 1 {
			count[wildLifeAnimal[i].id] <- count[wildLifeAnimal[i].id] + 1;
			W <- W + wildLifeAnimal[i].rarity;
		}
		
		loop i from: 0 to: numberOfSpecies {
			if (count[i] > 0) {
				uniqueAnimalAlive <- uniqueAnimalAlive + 1;
			}
		}
		
		W <- W * uniqueAnimalAlive;
	}
	
	reflex saveData {
		add R to: RList;
		add W to: WList;
		add localIncome to: localIncomeList;
		add govIncome to: govIncomeList;
		write length(RList);
		// save [RList, WList, localIncomeList, govIncomeList] to: "C:/Users/user/Documents/Maasai-Mara/ODEData/output.csv" type: csv;
	}
	
	init {
		
		create nature from: regionFile;
		create touristPath from: roadFile;
		create border from: immigrateFile;
		create border from: outsideFile;
		
		natureNetwork <- as_edge_graph(nature);
		roadNetwork <- as_edge_graph(touristPath);
		
		do createArea(popLessThan15, rgb(176, 224, 230), 1, 12);
		do createArea(pop15_49, rgb(135, 206, 235), 2, 8);
		do createArea(pop50_99, rgb(0, 191, 255), 4, 4);
		do createArea(pop100_249, rgb(30, 144, 255), 8, 1);
		do createArea(pop250_499, rgb(100, 149, 237), 17, 0);
		do createArea(pop500_9999, rgb(70, 130, 180), 30, 0);
		
		create nature from: outsideFile returns: outsideNature;
		
		huntingArea <- as_edge_graph(outsideNature);
		
		loop i from: 0 to: length(outsideNature) - 1{
			outsideNature[i].legalHunting <- true;
		}
		
		create hunter number: 200 returns: hunterList;
		loop i from: 0 to: length(hunterList) - 1 {
			hunterList[i].location <- any_location_in(one_of(huntingArea));
		}
		
		
	}
}

species resource {
	
	int epoches;
	
	init {
		epoches <- TIME_RANGE;
	}
	
	reflex given {
		list<wildLifeAnimal> near <- at_distance(wildLifeAnimal, RANGE);
		loop i from: 0 to: length(near) - 1 step: 1 {
			if (near[i].energy < near[i].reproduction) {
				near[i].energy <- near[i].energy + STEP;
				do die;
				return;
			}
		}

		Sum <- Sum + 1;
	}
	
	reflex expiring {
		if (epoches = 0) {
			do die;
		} else {
			epoches <- epoches - 1;
		}
	}
	
	aspect default {
		draw circle(CIRCLE_SIZE) color: #green;
	}
}

species distributedArea {
	rgb color;
	int peopleDensity;
	int numberOfDifferentAnimal;
	
	aspect default {
		draw shape color: color;
	}
}

species nature {
	int power;
	int pastEpoches;
	bool legalHunting;
	
	init {
		power <- 10 * STEP;
		legalHunting <- false;
	}
	
	reflex generating {
		if (pastEpoches = 0) {
			if (power < STEP) {
				return;
			}
			create resource number: int(power / STEP) returns: newResource;
			loop i from: 0 to: length(newResource) - 1 {
				newResource[i].location <- any_location_in(self);
			}
			pastEpoches <- TIME_RANGE;
		}
		pastEpoches <- pastEpoches - 1;
	}
	
	reflex drained {
		if (power <= 0) {
			power <- 0;
			return;
		}
		power <- power - int(length(at_distance(wildLifeAnimal, 200)) / 20);
		
		power <- power - int(length(at_distance(localPeople, 200)) / 10);
		power <- power - int(length(at_distance(visitor, 200)) / 10);
		power <- power - int(length(at_distance(hunter, 200)) / 25);
	}
	
	reflex replenish {
		int currentMonth <- mod(month, 12);
		if (currentMonth = 0) {
			govIncome <- govIncome - 1;
		}
		
		if (currentMonth = 3) {
			power <- power + 1.5 * STEP;
		}
	}
	
	aspect default {
		draw shape width: 4#m color: rgb(176, 224, 230);
	}
}

species border parent: nature {
	aspect notDefault {
		draw shape width: 4#m color: #gray;
	}
}

species touristPath {
	aspect default {
		draw shape width: 4#m color: rgb(255, 0, 0);
	}
}


species localPeople skills: [moving] {
	int spawningArea;
	 
	init {
		speed <- 5#m;
		location <- any_location_in(one_of(natureNetwork));
		
	}
	
	reflex move {
		do wander on: livingArea[spawningArea];
	}
	
	aspect default {
		draw circle(CIRCLE_SIZE) color: #red border: #black;
	}

}
     
species hunter skills: [moving] {
	
	reflex move {
		do wander on: huntingArea;
	}
	
	aspect default {
		draw circle(CIRCLE_SIZE) color: #pink border: #black;
	}
	
}

species visitor skills: [moving] {
	int numberOfTourist;
	
	init {
		int currentMonth <- mod(month, 12);
		
		if (currentMonth >= 4 and currentMonth <= 6) {
			numberOfTourist <- rnd(200, 500);
		} else if (currentMonth >= 7 and currentMonth <= 10) {
			numberOfTourist <- rnd(1200, 1500);
		} else {
			numberOfTourist <- rnd(500, 1200);
		}
		
		int budget <- numberOfTourist * AVERAGE_BUDGET;
		
		govIncome <- govIncome + budget * numberOfTourist * 0.7 / 1000000;
		localIncome <- localIncome + budget * numberOfTourist * 0.3 / 1000000;
		
		location <- any_location_in(one_of(roadNetwork));		
	}
	
	reflex move {
		do die;
	}		
	
	aspect default {
		draw circle(CIRCLE_SIZE) color: #red border: #black;
	}
}

species animal skills: [moving] {
	init {
		speed <- 5#m;
	}	
}


species wildLifeAnimal parent: animal {
	int id;
	int rarity;
	int energy;
	int reproduction;
	int spawningArea;
	
	int r;
	int b;
	int g;
	
	init {
		speed <- 20#m;
		energy <- 2000;
	}
	
	reflex alive {
		if (energy <= 0) {
			do die;
		}
	}
	
	reflex reproduction {
		if (energy > reproduction) {
			create wildLifeAnimal number: 1 returns: newAnimal;
			
			newAnimal[0].id <- id;
			newAnimal[0].rarity <- rarity;
			newAnimal[0].r <- r;
			newAnimal[0].b <- b;
			newAnimal[0].g <- g;
			newAnimal[0].reproduction <- reproduction;
			newAnimal[0].location <- self.location;
			
			energy <- energy - newAnimal[0].energy - RECOVER;
		}
		
	}
	
	reflex move {
		do wander speed: 10.0 on: livingArea[spawningArea];
		energy <- energy - 4;
		do wander speed: 20.0;
		energy <- energy - 20;
	}
	
	reflex hunted {
		if (length(at_distance(hunter, 20)) > 0 and flip(0.1) = true) {
			do die;
		}
	}

	aspect default {
		draw circle(5) color: #purple border: #black;
		
	}	
}




experiment test type: gui {
	output {
		display test type: opengl {
			
//			species touristPath aspect: default;
			species nature aspect: default;
			species distributedArea aspect: default;
			species border aspect: notDefault;
			species resource aspect: default;
			species visitor aspect: default;
			species wildLifeAnimal aspect: default;
			species localPeople aspect: default;
			species hunter aspect: default;		
	
			graphics test_graphics {

			}
		}
		
		display RInformation {
			chart "Resource of the environment (R) and Diversity of the environment (W)" type: series size: {1, 0.5} position: {0, 0} {
				data "R" value: R color: #blue;
				data "W" value: (W / 20) color: #red;
			}
			
		}
	
		display Income {
			chart "Local Income (I) and Government Income (P) by million" type: series size: {1, 0.5} position: {0, 0} {
				data "I" value: localIncome color: #blue;
				data "P" value: govIncome color: #red;
			}
		}
	}
}