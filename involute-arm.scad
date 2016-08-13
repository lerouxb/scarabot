use <MCAD/involute_gears.scad>;
use <Chamfers-for-OpenSCAD/Chamfer.scad>;

$fn=50;
draft=false;
includePinions=false;

// pitch radius by module
function prByM(t, m=1) = m * t / 2;

// pitch diameter by module
function pdByM(t, m=1) = m * t;

smallThickness = 5;
smallInnerDiameter = 4;
smallOuterDiameter = 13+0.2;

bigThickness = 7;
bigInnerDiameter = 8;
bigOuterDiameter = 22+0.2;

armLength = 120;

motorDiameter = 27.5+0.2;
motorMountThickness = 6;
motorDrillDiameter = 2.5;

wallThickness = 2;
gearWasherThickness = 1;
chamferHeight = 1;

gearModule = 0.75;
pressureAngle = 20;
gearDrillDiameter = 3.5;
//gearDrillDiameter = 3.2;
//gearDrillDiameter = 4;
bracketDrillDiameter = 2.5;
//bracketDrillDiameter = 3.3;
mountDrillDiameter = 2.5;
pinionDrillDiameter = 2.3;

pinionTeeth = 9;
pinionPitchRadius = prByM(pinionTeeth, gearModule);
echo("pitch", pdByM(pinionTeeth, gearModule)*PI/pinionTeeth);

// 2 3 5 7 11 13 17 19 23 29 31 37 41 43 47 53 59 61 67
//stage1Teeth = 31;
//stage2Teeth = 37;
//stage3Teeth = 43;
//stage4Teeth = 53;
stage1Teeth = 37;
stage2Teeth = 47;
stage3Teeth = 53;
stage4Teeth = 67;

//echo("gear ratio (3)", stage1Teeth/pinionTeeth * stage2Teeth/pinionTeeth * stage3Teeth/pinionTeeth);
//echo("gear ratio (4)", stage1Teeth/pinionTeeth * stage2Teeth/pinionTeeth * stage3Teeth/pinionTeeth * stage4Teeth/pinionTeeth);
//echo("gear ratio (3)", stage2Teeth/8 * stage3Teeth/pinionTeeth * stage4Teeth/pinionTeeth);
echo("gear ratio", stage1Teeth/pinionTeeth * stage2Teeth/pinionTeeth * stage3Teeth/pinionTeeth * stage4Teeth/pinionTeeth);
//echo("gear ratio", stage2Teeth/pinionTeeth * stage3Teeth/pinionTeeth * stage4Teeth/pinionTeeth);
// extra spacing between each axle
bracketClearance = 0.05; // 0.15 vs 0.25?

stage1Offset = pinionPitchRadius + prByM(stage1Teeth, gearModule) + bracketClearance;
stage2Offset = stage1Offset + pinionPitchRadius + prByM(stage2Teeth, gearModule) + bracketClearance;
stage3Offset = stage2Offset + pinionPitchRadius + prByM(stage3Teeth, gearModule) + bracketClearance;
stage4Offset = stage3Offset + pinionPitchRadius + prByM(stage4Teeth, gearModule) + bracketClearance;

motorOffset = armLength - stage4Offset;

echo("stage1Offset", stage1Offset);
echo("stage2Offset", stage2Offset, stage2Offset-stage1Offset);
echo("stage3Offset", stage3Offset, stage3Offset-stage2Offset);
echo("stage4Offset", stage4Offset, stage4Offset-stage3Offset);

//gearHeight = 5;
//gearHeight = 8;
gearHeight = 7;

// Tolerances for geometry connections.
teethtwist = 1;

gearClearance = 0.05;

boltDiameter = 8;
boltDrillDiameter = 6.75;
boltHeadDiameter = 14.7; // 14.38 in theory
boltNutThickness = 6.4; // 6.44 to 6.8

armHeight = bigThickness+wallThickness;
//armWidth = smallOuterDiameter+2*wallThickness;
armWidth = 15;
//armWidth = bigOuterDiameter + 4*wallThickness;

boardDrillDiameter = 2.5;
boardLength = 18.5;
boardWidth = 15.5;
boardThickness = 1.8;
boardCutoutDiameter = 3;
boardOffset = armHeight+4+3+1+1; // screw head, magnet, 1mm gap, chip height

pinsLength = boardLength;
pinsWidth = 2.5;
pinsHeight = 9 + 5;

hubDiameter = pinionPitchRadius*2 + wallThickness/3*4;
//

motorBracketRadius = (motorDiameter+motorMountThickness*2)/2;
bearingMountRadius = bigOuterDiameter/2+2*wallThickness;
squareEndX = armHeight;
//squareEndY = bigOuterDiameter + 4*wallThickness + 2*2;
squareEndY = motorBracketRadius*2;

encoderMountHoleOffset = squareEndX/2;
//output shaft is attached to the output gear
//sensor is attached to the same arm

towerHeight = 45; // all inclusive from base to top of the top bearing
towerGap = 8; // space below the bottom bearing to leave room for bolt head
towerBaseThickness = 5;
towerBaseWidth = 45;
towerScrewDrillDiameter = 3.5;
towerScrewOffset = wallThickness*3+towerScrewDrillDiameter/2;

largeWasherThickness = 1.5;

encoderBracketOffset = 40 + 3 - gearHeight/2 - gearWasherThickness - armHeight - largeWasherThickness - 1; // 1 is just adjustment because it ends up too far from the magnet
encoderBracketGap = 2;
encoderChipDiameter = 7;
encoderPinsLength = 20;
encoderPinsGap = 9.5;
encoderArmClearance = 0.2;

module involute(r, t, h, chamfer=false, hubD=0, circles=6) {
  if (draft) {
    cylinder(d=r*2, h=h);
  } else {
    intersection() {
      if (chamfer) {
        chamferCylinder(height=h, radius=r+2*gearModule, chamferHeight=2*gearModule);
      }
      union() {
        translate([0, 0, gearHeight])
        rotate([180, 0, 0])
        gear(
          number_of_teeth=t,
          circular_pitch=360 * r / t,
          gear_thickness = h/2,
          rim_thickness = h,
          rim_width = wallThickness/2,
          hub_thickness = h,
          hub_diameter = hubD,
          bore_diameter=0,
          circles=circles,
          clearance=gearClearance);
      }
    }
  }
}

module pinion() {
  translate([motorOffset, 0, -2*(gearWasherThickness+gearHeight)])
  difference() {
    involute(r=pinionPitchRadius, t=pinionTeeth, h=gearHeight, chamfer=true);
    translate([0, 0, -0.1])
    cylinder(d=pinionDrillDiameter, h=gearHeight+0.2, $fn=25);
    //cylinder(d=gearDrillDiameter, h=gearHeight+0.2, $fn=25);
  }
}

module pinionInsert() {
  difference() {
    union() {
      translate([0, 0, -gearHeight - gearWasherThickness])
      involute(r=pinionPitchRadius, t=pinionTeeth, h=gearHeight, circles=0);

      translate([0, 0, -gearWasherThickness])
      cylinder(r=pinionPitchRadius-0.1, h=gearWasherThickness+gearHeight, $fn=6);
    }

    translate([0, 0, -gearWasherThickness - gearHeight-0.1])
    cylinder(d=gearDrillDiameter, h=gearWasherThickness+gearHeight*2+0.2);
  }
}

module stage(teeth, offset, includePinion) {
  translate([offset, 0, -gearWasherThickness-gearHeight]) {
    difference() {
      involute(r=prByM(teeth, gearModule), t=teeth, h=gearHeight, chamfer=true, hubD=pinionPitchRadius*2 + wallThickness);

      translate([0, 0, -0.1])
      cylinder(r=pinionPitchRadius, h=gearHeight+0.2, $fn=6);
    }

    if (includePinions) {
      pinionInsert();
    }
  }
}

module stage1() {
  translate([0, 0, -2*(gearWasherThickness+gearHeight)-gearWasherThickness])
  rotate([180, 0, 0])
  stage(stage1Teeth, motorOffset+stage1Offset);
}

module stage2() {
  translate([0, 0, 0])
  stage(stage2Teeth, motorOffset+stage2Offset);
  //stage(stage2Teeth, 0);
}

module stage3() {
  translate([0, 0, -2*(gearWasherThickness+gearHeight)-gearWasherThickness])
  rotate([180, 0, 0])
  stage(stage3Teeth, motorOffset+stage3Offset);
}

module stage4() {
  translate([motorOffset+stage4Offset, 0, -gearWasherThickness-gearHeight])
  //rotate([180, 0, 0])
  difference() {
    union() {
      involute(r=prByM(stage4Teeth, gearModule), t=stage4Teeth, h=gearHeight, chamfer=true, hubD=boltHeadDiameter+2*wallThickness);
    }
    // hole
    translate([0, 0, -0.1])
    cylinder(d=boltDiameter, h=gearHeight+0.2);

    // space for bolt head
    translate([0, 0, -0.1])
    cylinder(d=boltHeadDiameter, h=gearHeight/2+0.1, $fn=6);
  }
}

module arm1() {
  difference() {
    union() {
      translate([0, -armWidth/2, 0])
      chamferCube(sizeX=armLength, sizeY=armWidth, sizeZ=armHeight, chamferHeight=1);

      // motor bracket positive
      translate([motorOffset, 0, 0])
      chamferCylinder(radius=motorBracketRadius, height=armHeight, chamferHeight=1);

      // rounded part for going around the bolt at the start
      chamferCylinder(radius=boltHeadDiameter/2+2*wallThickness, height=armHeight, chamferHeight=1);

      // part to join the start & motor bracket
      translate([0, -boltHeadDiameter/2-2*wallThickness, 0])
      chamferCube(sizeX=bearingMountRadius+motorBracketRadius, sizeY=boltHeadDiameter+4*wallThickness, sizeZ=armHeight, chamferHeight=1);

      // end bearing positive
      translate([armLength, 0, 0]) {
        chamferCylinder(radius=bearingMountRadius, height=armHeight, chamferHeight=1);
      }
    }

    // motor bracket negative
    translate([motorOffset, 0, -0.1])
    cylinder(d=motorDiameter, h=armHeight+0.2);

    // bearing negatives
    shaftHole(motorOffset+stage1Offset);
    shaftHole(motorOffset+stage2Offset);
    shaftHole(motorOffset+stage3Offset);

    // hole for a nut to stop it from spinning
    translate([0, 0, -0.1]) {
      cylinder(d=boltHeadDiameter, h=boltNutThickness+0.1, $fn=6);
      cylinder(d=boltDrillDiameter, h=armHeight+0.2);
    }

    // end bearing negatives
    translate([armLength, 0, -0.1])
    cylinder(d=bigOuterDiameter, h=bigThickness+0.1);
    translate([armLength, 0, -0.1])
    cylinder(d=bigOuterDiameter-2*wallThickness, h=armHeight+0.2);

    // holes for attaching the motor
    translate([motorOffset, 0, armHeight/2])
    rotate([90, 0, 0])
    translate([0, 0, -motorDiameter/2-motorMountThickness-0.1])
    cylinder(d=motorDrillDiameter, h=motorDiameter+motorMountThickness*2+0.2);


    // screw holes for attaching the encoder board
    translate([armLength, 0, 0]) {
      rotate([0, 0, 60])
      encoderMountHole();
      rotate([0, 0, -60])
      encoderMountHole();

      rotate([0, 0, 60+180])
      encoderMountHole();
      rotate([0, 0, -60+180])
      encoderMountHole();
    }
  }
}

module encoderMountHole() {
  rotate([0, 0, 90])
  translate([0, bearingMountRadius, armHeight/2])
  rotate([90, 0, 0])
  cylinder(d=mountDrillDiameter, h=wallThickness*4+0.2);
}

module shaftHole(offset, includeHoles) {
  diff = armHeight-armHeight;
  translate([offset, 0, -diff-0.1]) {
    cylinder(d=bracketDrillDiameter, h=armHeight+diff+0.2);
  }
}

module board() {
  translate([stage4Offset-boardLength/2, -boardWidth/2, -boardOffset-boardThickness])
  difference() {
    union() {
      cube([boardLength, boardWidth, boardThickness]);
      translate([0, 0, -pinsHeight])
      cube([pinsLength, pinsWidth, pinsHeight]);
      translate([0, boardWidth-pinsWidth, -pinsHeight])
      cube([pinsLength, pinsWidth, pinsHeight]);
    }
    translate([boardLength, boardWidth/2, -0.1])
    cylinder(d=boardCutoutDiameter, h=boardThickness+0.2);
  }
}
module tower() {
  translate([0, 0, -towerHeight]) {
    difference() {
      union() {
        chamferCylinder(height=towerHeight, radius=bigOuterDiameter/2+2*wallThickness, chamferHeight=1);
        chamferCube();
        translate([-towerBaseWidth/2, -towerBaseWidth/2, 0])
        chamferCube(sizeX=towerBaseWidth, sizeY=towerBaseWidth, sizeZ=towerBaseThickness, chamferHeight=1);
      }

      // center hole just smaller than the bearing
      translate([0, 0, -0.1])
      cylinder(d=bigOuterDiameter-2*wallThickness, h=towerHeight+0.2);

      // top bearing hole
      translate([0, 0, towerHeight-bigThickness])
      cylinder(d=bigOuterDiameter, h=bigThickness+0.1);

      // bottom bearing hole
      translate([0, 0, -0.1])
      cylinder(d=bigOuterDiameter, h=bigThickness+towerGap+0.1);

      // 4 screw holes
      translate([-towerBaseWidth/2+towerScrewOffset, -towerBaseWidth/2+towerScrewOffset, -0.1])
      cylinder(d=towerScrewDrillDiameter, h=towerHeight+0.2);
      translate([-towerBaseWidth/2+towerScrewOffset, towerBaseWidth/2-towerScrewOffset, -0.1])
      cylinder(d=towerScrewDrillDiameter, h=towerHeight+0.2);

      translate([towerBaseWidth/2-towerScrewOffset, -towerBaseWidth/2+towerScrewOffset, -0.1])
      cylinder(d=towerScrewDrillDiameter, h=towerHeight+0.2);
      translate([towerBaseWidth/2-towerScrewOffset, towerBaseWidth/2-towerScrewOffset, -0.1])
      cylinder(d=towerScrewDrillDiameter, h=towerHeight+0.2);
    }
  }
}

module arm2a() {
  translate([armLength, 0, armHeight+largeWasherThickness])
  rotate([0, 0, 180-18])
  difference() {
    union() {
      translate([0, -armWidth/2, 0])
      chamferCube(sizeX=armLength, sizeY=armWidth, sizeZ=armHeight, chamferHeight=1);

      // rounded part for going around the bolt at the start
      chamferCylinder(radius=boltHeadDiameter/2+2*wallThickness, height=armHeight, chamferHeight=1);

      // end bearing positive
      translate([armLength, 0, 0])
      chamferCylinder(radius=bigOuterDiameter/2+2*wallThickness, height=armHeight, chamferHeight=1);
    }

    // a nut-shaped hole so it cannot turn separately
    translate([0, 0, -0.1])
    cylinder(d=boltHeadDiameter, h=boltNutThickness+0.1, $fn=6);
    translate([0, 0, -0.1])
    cylinder(d=boltDrillDiameter, h=armHeight+0.2);

    // end bearing negatives
    translate([armLength, 0, wallThickness])
    cylinder(d=bigOuterDiameter, h=bigThickness+0.1);
    translate([armLength, 0, -0.1])
    cylinder(d=bigOuterDiameter-2*wallThickness, h=armHeight+0.2);
  }
}
module arm2b() {
  translate([armLength, 0, armHeight+largeWasherThickness])
  rotate([0, 0, 180+15])
  rotate([180, 0, 0])
  difference() {
    union() {
      // rounded part for going around the bolt at the start
      chamferCylinder(radius=boltHeadDiameter/2+2*wallThickness, height=armHeight, chamferHeight=1);

      // first arm part
      translate([0, -armWidth/2, 0])
      chamferCube(sizeX=armLength/3*2, sizeY=armWidth, sizeZ=armHeight, chamferHeight=1);

      // second arm part
      translate([armLength/3*2, -armWidth/2, -armHeight])
      chamferCube(sizeX=armLength/3, sizeY=armWidth, sizeZ=armHeight, chamferHeight=1);

      // diagonal block to join the two parts
      intersection() {
        // the box around both arm parts
        translate([0, -armWidth/2, -armHeight])
        cube([armLength, armWidth, armHeight*2]);

        // a cube rotated 45 degrees
        translate([armLength/3*2, 0, 0])
        rotate([0, 45, 0])
        translate([-armHeight*sqrt(2)/2-1, -armWidth/2, -armHeight*sqrt(2)/2])
        chamferCube(sizeX=armHeight*sqrt(2)+2, sizeY=armWidth, sizeZ=armHeight*sqrt(2));
      }

      // end-bearing part
      translate([armLength, 0, -armHeight])
      chamferCylinder(radius=bigOuterDiameter/2+2*wallThickness, height=armHeight, chamferHeight=1);
    }

    // a nut-shaped hole so it cannot turn separately
    translate([0, 0, -0.1])
    cylinder(d=boltHeadDiameter, h=boltNutThickness+0.1, $fn=6);
    translate([0, 0, -0.1])
    cylinder(d=boltDrillDiameter, h=armHeight+0.2);

    // end bearing negatives
    translate([armLength, 0, -armHeight-0.1])
    cylinder(d=bigOuterDiameter, h=bigThickness+0.1);
    translate([armLength, 0, -armHeight-0.1])
    cylinder(d=bigOuterDiameter-2*wallThickness, h=armHeight+0.2);
  }
}

module arc(height, depth, radius, degrees) {
  // This dies a horible death if it's not rendered here
  // -- sucks up all memory and spins out of control
  render() {
    difference() {
      // Outer ring
      rotate_extrude($fn = 100)
      translate([radius - height, 0, 0])
      square([height,depth]);

      // Cut half off
      translate([0,-(radius+1),-.5])
      cube ([radius+1,(radius+1)*2,depth+1]);

      // Cover the other half as necessary
      rotate([0,0,180-degrees])
      translate([0,-(radius+1),-.5])
      cube ([radius+1,(radius+1)*2,depth+1]);
    }
  }
}

module encoderBracket(reverse) {
  sizeX = bearingMountRadius + encoderPinsLength/2 + 3*wallThickness;
  sizeY = encoderPinsGap;
  sizeZ = armHeight + largeWasherThickness + encoderBracketOffset + wallThickness + encoderBracketGap + wallThickness;

  degrees = 60;
  degreesExtra = 5;
  rotationSign = reverse ? -1 : 1;
  rotationOffset = reverse ? 90+60 : 90;
  degreesExtra = reverse ? -15 : 15;

  translate([armLength, 0, 0])
  rotate([0, 0, rotationSign*60])
  difference() {
    union() {
      // positive parts
      intersection() {
        union() {
          // main block
          translate([-bearingMountRadius-2*wallThickness, -sizeY/2, 0])
          chamferCube(sizeX=sizeX, sizeY=sizeY, sizeZ=sizeZ, chamferHeight=1);

          // rounded part to secure it
          rotate([0, 0, degrees + degreesExtra*rotationSign - rotationOffset])
          arc(bearingMountRadius + 2*wallThickness, armHeight, bearingMountRadius+2*wallThickness, degrees+degreesExtra*2*rotationSign);
        }

        chamferCylinder(radius=bearingMountRadius + 2*wallThickness, height=sizeZ, chamferHeight=1);
      }
    }

    // main chamferred gap cylinder
    translate([wallThickness/2, 0, -1])
    chamferCylinder(radius=bearingMountRadius-wallThickness, height=armHeight + largeWasherThickness + encoderBracketOffset + 1, chamferHeight=1);

    // gap around the bottom arm and large washer
    translate([0, 0, -0.1])
    cylinder(r=bearingMountRadius, h=armHeight + largeWasherThickness + 0.1);

    // pins gap
    translate([-encoderPinsLength/2, -sizeY/2 - 0.1, armHeight + largeWasherThickness + encoderBracketOffset + wallThickness])
    cube([encoderPinsLength, sizeY+0.2, encoderBracketGap]);

    // gap below the chip for inserting and also for the chip itself to fit
    translate([-encoderChipDiameter/2, -sizeY/2-0.1, armHeight + largeWasherThickness + encoderBracketOffset - 0.1])
    cube([encoderChipDiameter/2 + encoderPinsLength/2 - wallThickness/2, sizeY+0.2, wallThickness + 0.1]);

    // screw hole closest to the arm
    translate([-bearingMountRadius-2*wallThickness-0.1, 0, armHeight/2])
    rotate([0, 90, 0])
    cylinder(d=mountDrillDiameter, h=wallThickness*2+0.2);

    // screw hole 60 degrees away
    rotate([0, 0, rotationSign*60])
    translate([-bearingMountRadius-2*wallThickness-0.1, 0, armHeight/2])
    rotate([0, 90, 0])
    cylinder(d=mountDrillDiameter, h=wallThickness*2+0.2);
  }
}

module testBracket() {
  extra = 5;
  x = stage4Offset + extra*2;
  y = 7;
  z = armHeight;

  difference() {
    union() {
      translate([-extra, -y/2, 0])
      chamferCube(sizeX=x, sizeY=y, sizeZ=z, chamferHeight=1);

      translate([stage4Offset, 0, 0])
      chamferCylinder(radius=bigOuterDiameter/2+2*wallThickness, height=armHeight, chamferHeight=1);

    }

    translate([0, 0, -0.1])
    cylinder(d=bracketDrillDiameter, h=z+0.2);

    translate([stage1Offset, 0, -0.1])
    cylinder(d=bracketDrillDiameter, h=z+0.2);
    translate([stage2Offset, 0, -0.1])
    cylinder(d=bracketDrillDiameter, h=z+0.2);
    translate([stage3Offset, 0, -0.1])
    cylinder(d=bracketDrillDiameter, h=z+0.2);

    // TODO: rather take out space for a bearing
    //translate([stage4Offset, 0, -0.1])
    //cylinder(d=bracketDrillDiameter, h=z+0.2);

    translate([stage4Offset, 0, armHeight-bigThickness])
    cylinder(d=bigOuterDiameter, h=bigThickness+0.1);
    translate([stage4Offset, 0, -0.1])
    cylinder(d=bigOuterDiameter-2*wallThickness, h=armHeight+0.1);

  }
}

module others() {
  translate([armLength, 0, 0]) {
    translate([0, 0, armHeight])
    cylinder(r=bigOuterDiameter/2+2*wallThickness, h=largeWasherThickness-0.001);

    translate([0, 0, armHeight*2+largeWasherThickness])
    cylinder(d=boltHeadDiameter, h=boltNutThickness, $fn=6);

    translate([0, 0, -gearWasherThickness-gearHeight/2])
    cylinder(d=8, h=40);

    translate([0, 0, -gearWasherThickness-gearHeight/2-boltNutThickness])
    cylinder(d=boltHeadDiameter, h=boltNutThickness, $fn=6);

    translate([0, 0, 40-gearHeight/2-gearWasherThickness])
    cylinder(d=6, h=2.5);
  }
}

module snapPin() {
  cutoutRadius = 15;

  outerRadius = bigInnerDiameter/2 + wallThickness;
  outerDiameter = outerRadius*2;

  topHeight = 6 * wallThickness;
  bottomHeight = wallThickness;
  pinHeight = 2*armHeight + largeWasherThickness + bottomHeight + topHeight;

  difference() {
    union() {
      // top part to lock it in place
      translate([0, 0, 2*armHeight + largeWasherThickness])
      intersection() {
        union() {
          chamferCylinder(radius=outerRadius, height=topHeight, chamferHeight=wallThickness);
          //cylinder(r=outerRadius, h=topHeight/2);
        }

        translate([-bigInnerDiameter/2, -bigInnerDiameter/2 - wallThickness - 0.1, -0.1])
        cube([bigInnerDiameter, bigInnerDiameter + wallThickness*2 + 0.2, topHeight+0.2]);
      }

      // main body
      translate([0, 0, -bottomHeight])
      cylinder(d=bigInnerDiameter, h=pinHeight);

      // bottom part to lock it in place
      translate([0, 0, -bottomHeight])
      cylinder(r=outerRadius, h=bottomHeight);
    }

    // main cavity
    translate([0, 0, -bottomHeight-0.1])
    cylinder(d=bigInnerDiameter - 2*wallThickness, h=pinHeight+0.2);

    // slice out part of it so it can be bent and inserted
    //translate([outerDiameter/2, 0, pinHeight/3])
    //rotate([-90, cutoutRadius/2, 90])
    //arc(pinHeight/2+wallThickness*2, outerDiameter, pinHeight/2+wallThickness*2, cutoutRadius);

    cutoutWidth = bigInnerDiameter/2;
    translate([-outerDiameter/2 - 0.1, -cutoutWidth/2, pinHeight/3 - bottomHeight])
    cube([outerDiameter+0.2, cutoutWidth, pinHeight/3*2+0.1]);
  }
}

//pinionInsert();
//pinion();
//stage1();
//stage2();
//stage3();
//stage4();
arm1();
//arm2a();
//arm2b();
//board();
//tower();
//encoderBracket(false);
//encoderBracket(true);
//snapPin();

//others();
//testBracket();

  /*
  difference() {
    involute(r=prByM(9, gearModule), t=9, h=gearHeight, chamfer=true);
    translate([0, 0, -0.1])
    cylinder(d=3.2, h=gearHeight+0.2, $fn=25);
  }
  */
