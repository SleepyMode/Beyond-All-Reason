return {
	raptor_turretl_antiair = {
		acceleration = 0.0115,
		activatewhenbuilt = true,
		autoheal = 1,

		brakerate = 0.0115,
		buildcostenergy = 6000,
		buildcostmetal = 240,
		builddistance = 500,
		builder = false,
		buildpic = "raptors/raptor_turretl_antiair.DDS",
		buildtime = 5200,
		canattack = true,
		canreclaim = false,
		canrestore = false,
		canstop = "1",
		capturable = false,
		category = "BOT MOBILE WEAPON ALL NOTSUB NOTSHIP NOTAIR NOTHOVER SURFACE RAPTOR EMPABLE",
		collisionvolumeoffsets = "0 -15 0",
		collisionvolumescales = "40 50 40",
		collisionvolumetype = "box",
		--energystorage = 500,
		explodeas = "tentacle_death",
		--extractsmetal = 0.001,
		footprintx = 4,
		footprintz = 4,
		idleautoheal = 15,
		idletime = 300,
		levelground = false,
		mass = 1400,
		maxdamage = 11100,
		maxslope = 255,
		maxvelocity = 0,
		maxwaterdepth = 0,
		movementclass = "NANO",
		noautofire = false,
		nochasecategory = "MOBILE",
		objectname = "Raptors/raptor_turretl_red_v2.s3o",
		--reclaimspeed = 200,
		repairable = false,
		script = "Raptors/raptor_turretl_v2.cob",
		seismicsignature = 0,
		selfdestructas = "tentacle_death",
		side = "THUNDERBIRDS",
		sightdistance = 500,
		smoothanim = true,
		turninplace = true,
		turninplaceanglelimit = 90,
		turnrate = 1840,
		unitname = "raptord2",
		upright = false,
		waterline = 1,
		workertime = 100,
		customparams = {
			subfolder = "other/raptors",
			model_author = "LathanStanley, Beherith",
			normalmaps = "yes",
			normaltex = "unittextures/chicken_m_normals.png",
			treeshader = "yes",
		},
		sfxtypes = {
			explosiongenerators = {
				[1] = "custom:blood_spray",
				[2] = "custom:blood_explode",
				[3] = "custom:dirt",
			},
			pieceexplosiongenerators = {
				[1] = "blood_spray",
				[2] = "blood_spray",
				[3] = "blood_spray",
			},
		},
		weapondefs = {
			weapon = {
				areaofeffect = 128,
				avoidfriendly = false,
				burnblow = true,
				--cegtag = "sporetrail-large",
				collidefriendly = false,
				craterboost = 0,
				cratermult = 0,
				cameraShake = 700,
				dance = 20,
				edgeeffectiveness = 0.35,
				explosiongenerator = "custom:genericshellexplosion-huge-bomb",
				firestarter = 0,
				flighttime = 8,
				firesubmersed = true,
				impulseboost = 0,
				impulsefactor = 0.4,
				interceptedbyshieldtype = 4,
				metalpershot = 0,
				model = "SimpleFlareXL.s3o",
				name = "Deadly Defensive Spores",
				noselfdamage = true,
				range = 1000,
				reloadtime = 6,
				smoketrail = true,
				smokePeriod = 2,
				smoketime = 45,
				smokesize = 10.5,
				smokecolor = 1.0,
				soundhit = "spore_explo",
				soundstart = "spore_xl",
				soundstartvolume = 9,
				startvelocity = 1000,
				texture1 = "orangenovaexplo",
				texture2 = "sporetrail_xl",
				tolerance = 60000,
				tracks = true,
				trajectoryheight = 2,
				turnrate = 60000,
				turret = true,
				waterweapon = true,
				weaponacceleration = 40,
				weapontype = "MissileLauncher",
				weaponvelocity = 2000,
				wobble = 32000,
				damage = {
					default = 20,
					bombers = 2000,
					fighters = 2000,
					vtol = 2000,
				},
			},
			-- cc_laser = {
			-- 	areaofeffect = 64,
			-- 	avoidfeature = false,
			-- 	beamtime = 2.4,
			-- 	cameraShake = 200,
			-- 	corethickness = 0.3,
			-- 	craterareaofeffect = 0,
			-- 	craterboost = 0,
			-- 	cratermult = 0,
			-- 	edgeeffectiveness = 0.55,
			-- 	explosiongenerator = "custom:laserhit-large-yellow",
			-- 	firestarter = 90,
			-- 	impulseboost = 0,
			-- 	impulsefactor = 0,
			-- 	intensity = 1.0,
			-- 	laserflaresize = 5.5,
			-- 	leadLimit = 16,
			-- 	minIntensity = 0.8,
			-- 	name = "HeatRay",
			-- 	noselfdamage = true,
			-- 	range = 400,
			-- 	reloadtime = 5.5,
			-- 	rgbcolor = "0.47 0.21 0",
			-- 	rgbcolor2 = "1 0.88 0.5",
			-- 	soundhitdry = "",
			-- 	soundhitwet = "sizzle",
			-- 	soundstart = "raptorlaser",
			-- 	--soundhitvolume = 6,
			-- 	soundstartvolume = 34,
			-- 	soundtrigger = 1,
			-- 	--sweepFire = true,
			-- 	targetborder = 0.3,
			-- 	targetmoveerror = 0.1,
			-- 	thickness = 4.8,
			-- 	tolerance = 60000,
			-- 	turret = true,
			-- 	weapontype = "BeamLaser",
			-- 	weaponvelocity = 700,
			-- 	damage = {
			-- 		raptor = 0.1,
			-- 		default = 28000,
			-- 	},
			-- },
		},
		weapons = {
			[1] = {
				def = "WEAPON",
				onlytargetcategory = "VTOL",
			},
			-- [2] = {
			-- 	def = "CC_LASER",
			-- },
		},
	},
}
