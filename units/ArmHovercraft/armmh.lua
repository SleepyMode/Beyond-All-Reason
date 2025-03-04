return {
	armmh = {
		acceleration = 0.04561,
		brakerate = 0.04561,
		buildcostenergy = 3000,
		buildcostmetal = 175,
		buildpic = "ARMMH.DDS",
		buildtime = 3298,
		canmove = true,
		category = "ALL HOVER MOBILE WEAPON NOTSUB NOTSHIP NOTAIR SURFACE EMPABLE",
		collisionvolumeoffsets = "0 -2 0",
		collisionvolumescales = "33 15 43",
		collisionvolumetype = "Box",
		corpse = "DEAD",
		explodeas = "mediumexplosiongeneric",
		footprintx = 3,
		footprintz = 3,
		idleautoheal = 5,
		idletime = 1800,
		maxdamage = 530,
		maxslope = 16,
		maxvelocity = 2.13,
		maxwaterdepth = 0,
		movementclass = "HOVER3",
		nochasecategory = "VTOL",
		objectname = "Units/ARMMH.s3o",
		script = "Units/ARMMH.cob",
		seismicsignature = 0,
		selfdestructas = "mediumExplosionGenericSelfd",
		sightdistance = 509,
		turninplace = true,
		turninplaceanglelimit = 90,
		turninplacespeedlimit = 1.5972,
		turnrate = 470,
		customparams = {
			unitgroup = 'weapon',
			model_author = "Beherith",
			normaltex = "unittextures/Arm_normal.dds",
			subfolder = "armhovercraft",
		},
		featuredefs = {
			dead = {
				blocking = false,
				category = "corpses",
				collisionvolumeoffsets = "0.23698425293 1.26007220703 -0.625221252441",
				collisionvolumescales = "29.5979919434 18.3375244141 32.5498809814",
				collisionvolumetype = "Box",
				damage = 286,
				energy = 0,
				featuredead = "HEAP",
				footprintx = 3,
				footprintz = 3,
				height = 20,
				hitdensity = 100,
				metal = 106,
				object = "Units/armmh_dead.s3o",
				reclaimable = true,
				seqnamereclamate = "TREE1RECLAMATE",
				world = "All Worlds",
			},
			heap = {
				blocking = false,
				category = "heaps",
				collisionvolumescales = "55.0 4.0 6.0",
				collisionvolumetype = "cylY",
				damage = 143,
				energy = 0,
				footprintx = 3,
				footprintz = 3,
				height = 4,
				hitdensity = 100,
				metal = 42,
				object = "Units/arm3X3A.s3o",
				reclaimable = true,
				resurrectable = 0,
				seqnamereclamate = "TREE1RECLAMATE",
				world = "All Worlds",
			},
		},
		sfxtypes = {
			explosiongenerators = {
				[1] = "custom:waterwake-small-hover",
				[2] = "custom:bowsplash-small-hover",
				[3] = "custom:hover-wake-small",
			},
			pieceexplosiongenerators = {
				[1] = "deathceg2",
				[2] = "deathceg3",
				[3] = "deathceg4",
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
				[1] = "hovt1vrocok",
			},
			select = {
				[1] = "hovt1vrocsel",
			},
		},
		weapondefs = {
			armmh_weapon = {
				areaofeffect = 64,
				avoidfeature = false,
				cegtag = "missiletrailsmall-starburst",
				craterareaofeffect = 0,
				craterboost = 0,
				cratermult = 0,
				edgeeffectiveness = 0.15,
				explosiongenerator = "custom:genericshellexplosion-medium-bomb",
				firestarter = 100,
				flighttime = 10,
				impulseboost = 0.123,
				impulsefactor = 0.123,
				metalpershot = 0,
				model = "corkbmissl1.s3o",
				name = "Light long-range g2g starburst rocket launcher",
				noselfdamage = true,
				range = 710,
				reloadtime = 6,
				smoketrail = true,
				smokePeriod = 9,
				smoketime = 28,
				smokesize = 10,
				smokecolor = 0.7,
				smokeTrailCastShadow = false,
				castshadow = true, --projectile
				soundhit = "xplomed4",
				soundhitwet = "splssml",
				soundstart = "Rockhvy1",
				texture1 = "null",
				texture2 = "smoketrailbar",
				texture3 = "null",
				tolerance = 4000,
				turnrate = 15000,
				weaponacceleration = 100,
				weapontimer = 2.3,
				weapontype = "StarburstLauncher",
				weaponvelocity = 600,
				damage = {
					default = 300,
					subs = 150,
				},
			},
		},
		weapons = {
			[1] = {
				badtargetcategory = "MOBILE",
				def = "ARMMH_WEAPON",
				onlytargetcategory = "SURFACE",
			},
		},
	},
}
