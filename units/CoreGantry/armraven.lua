return {
	armraven = {
		acceleration = 0.108,
		brakerate = 0.564,
		buildcostenergy = 80000,
		buildcostmetal = 4800,
		buildpic = "ARMRAVEN.DDS",
		buildtime = 127000,
		canmove = true,
		category = "WEAPON NOTSUB NOTAIR NOTHOVER SURFACE",
		collisionvolumeoffsets = "0 0 2",
		collisionvolumescales = "60 53 30",
		collisionvolumetype = "box",
		corpse = "DEAD",
		description = "Heavy Rocket Kbot",
		explodeas = "hugeExplosionGeneric",
		footprintx = 4,
		footprintz = 4,
		idleautoheal = 5,
		idletime = 1800,
		mass = 200000,
		maxdamage = 5500,
		maxslope = 20,
		maxvelocity = 1.6,
		maxwaterdepth = 12,
		movementclass = "HKBOT4",
		name = "Catapult",
		nochasecategory = "VTOL",
		objectname = "ARMRAVEN",
		seismicsignature = 0,
		selfdestructas = "hugeExplosionGeneric",
		sightdistance = 700,
		turninplaceanglelimit = 140,
		turninplacespeedlimit = 1.056,
		turnrate = 979,
		upright = true,
		customparams = {
			death_sounds = "generic",
		},
		featuredefs = {
			dead = {
				blocking = true,
				category = "corpses",
				collisionvolumeoffsets = "3.19359588623 0.0 1.04564666748",
				collisionvolumescales = "66.3871917725 26.0 41.4744720459",
				collisionvolumetype = "Box",
				damage = 3300,
				description = "Catapult Wreckage",
				energy = 0,
				featuredead = "HEAP",
				featurereclamate = "SMUDGE01",
				footprintx = 3,
				footprintz = 3,
				height = 40,
				hitdensity = 100,
				metal = 2958,
				object = "ARMRAVEN_DEAD",
				reclaimable = true,
				seqnamereclamate = "TREE1RECLAMATE",
				world = "All Worlds",
			},
			heap = {
				blocking = false,
				category = "heaps",
				damage = 1650,
				description = "Catapult Heap",
				energy = 0,
				featurereclamate = "SMUDGE01",
				footprintx = 3,
				footprintz = 3,
				height = 4,
				hitdensity = 100,
				metal = 1183,
				object = "3X3C",
                collisionvolumescales = "55.0 4.0 6.0",
                collisionvolumetype = "cylY",
				reclaimable = true,
				resurrectable = 0,
				seqnamereclamate = "TREE1RECLAMATE",
				world = "All Worlds",
			},
		},
		sfxtypes = { 
 			pieceExplosionGenerators = { 
				"deathceg2",
				"deathceg3",
				"deathceg4",
			},
		},
		sounds = {
			canceldestruct = "cancel2",
			underattack = "warning1",
			cant = {
				[1] = "cantdo4",
			},
			count = {
				[1] = "count6",
				[2] = "count5",
				[3] = "count4",
				[4] = "count3",
				[5] = "count2",
				[6] = "count1",
			},
			ok = {
				[1] = "mavbok1",
			},
			select = {
				[1] = "mavbsel1",
			},
		},
		weapondefs = {
			exp_heavyrocket = {
				areaofeffect = 96,
				avoidfeature = false,
				burst = 20,
				burstrate = 0.12,
				craterareaofeffect = 96,
				craterboost = 0,
				cratermult = 0,
				dance = 30,
				edgeeffectiveness = 0.5,
				cegTag = "missiletrailsmall",
				explosiongenerator = "custom:genericshellexplosion-large",
				firestarter = 70,
				flighttime = 3,
				impulseboost = 0.123,
				impulsefactor = 0.123,
				metalpershot = 0,
				model = "exphvyrock",
				movingaccuracy = 600,
				name = "RavenCatapultRockets",
				noselfdamage = true,
				proximitypriority = -1,
				range = 1350,
				reloadtime = 15,
				smoketrail = false,
				soundhit = "rockhit",
				soundhitwet = "splsmed",
				soundhitwetvolume = 0.5,
				soundstart = "rapidrocket3",
				startvelocity = 110,
				texture2 = "coresmoketrail",
				trajectoryheight = 1,
				turnrate = 0,
				turret = true,
				weaponacceleration = 110,
				weapontimer = 6,
				weapontype = "MissileLauncher",
				weaponvelocity = 550,
				wobble = 2000,
				damage = {
					default = 450,
					subs = 5,
				},
				customparams = {
					light_multiplier = "0.25",		-- used by projectile lights widget
				},
			},
		},
		weapons = {
			[1] = {
				badtargetcategory = "VTOL GROUNDSCOUT",
				def = "EXP_HEAVYROCKET",
				onlytargetcategory = "SURFACE",
			},
		},
	},
}
