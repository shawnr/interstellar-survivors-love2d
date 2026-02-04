-- Episodes Data
-- Story content and configuration for each episode

EpisodesData = {
    [1] = {
        id = 1,
        title = "Spin Cycle",
        tagline = "They just want to be friends. Aggressively.",
        startingMessage = "WELCOME COMMITTEE INBOUND",
        backgroundPath = "assets/images/episodes/ep1/bg_ep1.png",

        introPanels = {
            {
                imagePath = "assets/images/episodes/ep1/ep1_intro_1.png",
                lines = {
                    "Mission: Collect samples from an uplift project that got out of hand.",
                    "Spiders. Very smart spiders.",
                    "Nothing ever goes wrong with spiders.",
                }
            },
            {
                imagePath = "assets/images/episodes/ep1/ep1_intro_2.png",
                lines = {
                    "Update: The spiders have spotted us.",
                    "They're very excited. They're sending gifts.",
                    "The gifts are approaching at ramming speed.",
                }
            },
            {
                imagePath = "assets/images/episodes/ep1/ep1_intro_3.png",
                lines = {
                    "Revised mission: Collect samples, survive welcome party.",
                    "Do NOT insult their poetry.",
                    "Apparently the last research team did that.",
                }
            },
        },

        endingPanels = {
            {
                imagePath = "assets/images/episodes/ep1/ep1_ending_1.png",
                lines = {
                    "Sample collection complete: 847 artifacts cataloged...",
                    "...including one epic poem about a fly.",
                    "It's 11,000 verses long.",
                }
            },
            {
                imagePath = "assets/images/episodes/ep1/ep1_ending_2.png",
                lines = {
                    "A spider named Maserati has stowed away in the sample bay.",
                    "She claims diplomatic immunity.",
                    "She's also reorganized our filing system.",
                }
            },
            {
                imagePath = "assets/images/episodes/ep1/ep1_ending_3.png",
                lines = {
                    "Research Spec unlocked:",
                    "Their silk has remarkable tensile properties.",
                    "Maserati is very smug about this.",
                }
            },
        },

        unlockCondition = "start",

        bossClass = "CulturalAttache",
        spawnConfig = {
            { waveRange = {1, 2}, weights = {
                { class = "GreetingDrone", weight = 70 },
                { class = "Asteroid", weight = 30, args = {level = 1} },
            }},
            { waveRange = {3, 4}, weights = {
                { class = "GreetingDrone", weight = 40 },
                { class = "Asteroid", weight = 30, args = {level = {1, 2}} },
                { class = "SilkWeaver", weight = 30 },
            }},
            { waveRange = {5, 7}, weights = {
                { class = "GreetingDrone", weight = 30 },
                { class = "Asteroid", weight = 25, args = {level = {1, 3}} },
                { class = "SilkWeaver", weight = 45 },
            }},
        },
    },

    [2] = {
        id = 2,
        title = "Productivity Review",
        tagline = "Your feedback is important to us.",
        startingMessage = "QUARTERLY TARGETS: MANDATORY",
        backgroundPath = "assets/images/episodes/ep2/bg_ep2.png",

        introPanels = {
            {
                imagePath = "assets/images/episodes/ep2/ep2_intro_1.png",
                lines = {
                    "Standard mineral survey. Corporate has assigned consultants...",
                    "...to ensure we meet quarterly research targets.",
                    "This is fine.",
                }
            },
            {
                imagePath = "assets/images/episodes/ep2/ep2_intro_2.png",
                lines = {
                    "The consultants have arrived.",
                    "They have questions about our 'process' and our 'workflow.'",
                    "They have exploded near the hull.",
                }
            },
            {
                imagePath = "assets/images/episodes/ep2/ep2_intro_3.png",
                lines = {
                    "New priority: Collect ore samples. Ignore the helpers.",
                    "If a drone asks you to rate your experience...",
                    "...just keep shooting.",
                }
            },
        },

        endingPanels = {
            {
                imagePath = "assets/images/episodes/ep2/ep2_ending_1.png",
                lines = {
                    "Survey complete. Mineral yield: Excellent.",
                    "Consultant survival rate: Unknown.",
                    "We're not tracking that metric.",
                }
            },
            {
                imagePath = "assets/images/episodes/ep2/ep2_ending_2.png",
                lines = {
                    "Corporate has sent a follow-up survey about the follow-up survey.",
                    "We have filed it appropriately.",
                    "The file is labeled 'dumb'.",
                }
            },
            {
                imagePath = "assets/images/episodes/ep2/ep2_ending_3.png",
                lines = {
                    "Research Spec unlocked: The drones' targeting software...",
                    "...was actually pretty good. We've repurposed it.",
                    "Don't tell corporate.",
                }
            },
        },

        unlockCondition = "episode_1",

        bossClass = "ProductivityLiaison",
        spawnConfig = {
            { waveRange = {1, 2}, weights = {
                { class = "SurveyDrone", weight = 60 },
                { class = "Asteroid", weight = 40, args = {level = 1} },
            }},
            { waveRange = {3, 4}, weights = {
                { class = "SurveyDrone", weight = 35 },
                { class = "EfficiencyMonitor", weight = 30 },
                { class = "Asteroid", weight = 35, args = {level = {1, 2}} },
            }},
            { waveRange = {5, 7}, weights = {
                { class = "SurveyDrone", weight = 30 },
                { class = "EfficiencyMonitor", weight = 40 },
                { class = "Asteroid", weight = 30, args = {level = {1, 3}} },
            }},
        },
    },

    [3] = {
        id = 3,
        title = "Whose Idea Was This?",
        tagline = "Reality is more of a suggestion.",
        startingMessage = "PROBABILITY: OPTIONAL",
        backgroundPath = "assets/images/episodes/ep3/bg_ep3.png",

        introPanels = {
            {
                imagePath = "assets/images/episodes/ep3/ep3_intro_1.png",
                lines = {
                    "The Improbability Drive test was supposed to be contained.",
                    "It was not contained.",
                    "Reality is now 'optional' in this sector.",
                }
            },
            {
                imagePath = "assets/images/episodes/ep3/ep3_intro_2.png",
                lines = {
                    "Current status: Things are becoming other things.",
                    "Some of those things are hostile.",
                    "One of them is a whale. The whale seems fine.",
                }
            },
            {
                imagePath = "assets/images/episodes/ep3/ep3_intro_3.png",
                lines = {
                    "Objective: Collect probability particles for study.",
                    "Try not to become something else yourself.",
                    "If you do, please file Form 42-B.",
                }
            },
        },

        endingPanels = {
            {
                imagePath = "assets/images/episodes/ep3/ep3_ending_1.png",
                lines = {
                    "Particles collected. Reality is stabilizing.",
                    "Most things are back to being themselves.",
                    "The sofa remains unexplained.",
                }
            },
            {
                imagePath = "assets/images/episodes/ep3/ep3_ending_2.png",
                lines = {
                    "Final inventory includes 47 impossible objects...",
                    "...and one cup of tea that appeared exactly when someone needed it.",
                    "Coincidence rate: Improbable.",
                }
            },
            {
                imagePath = "assets/images/episodes/ep3/ep3_ending_3.png",
                lines = {
                    "Research Spec unlocked: We've learned to predict small impossibilities.",
                    "This should not be possible.",
                    "That's rather the point.",
                }
            },
        },

        unlockCondition = "episode_2",

        bossClass = "ImprobabilityEngine",
        spawnConfig = {
            { waveRange = {1, 2}, weights = {
                { class = "ProbabilityFluctuation", weight = 60 },
                { class = "Asteroid", weight = 40, args = {level = 1} },
            }},
            { waveRange = {3, 4}, weights = {
                { class = "ProbabilityFluctuation", weight = 35 },
                { class = "ParadoxNode", weight = 30 },
                { class = "Asteroid", weight = 35, args = {level = {1, 2}} },
            }},
            { waveRange = {5, 7}, weights = {
                { class = "ProbabilityFluctuation", weight = 30 },
                { class = "ParadoxNode", weight = 40 },
                { class = "Asteroid", weight = 30, args = {level = {1, 3}} },
            }},
        },
    },

    [4] = {
        id = 4,
        title = "Garbage Day",
        tagline = "One civilization's apocalypse is another's opportunity.",
        startingMessage = "SALVAGE RIGHTS: CONTESTED",
        backgroundPath = "assets/images/episodes/ep4/bg_ep4.png",

        introPanels = {
            {
                imagePath = "assets/images/episodes/ep4/ep4_intro_1.png",
                lines = {
                    "Salvage mission. This debris field dates back...",
                    "...to a war nobody remembers. One civilization's apocalypse...",
                    "...is another's research opportunity.",
                }
            },
            {
                imagePath = "assets/images/episodes/ep4/ep4_intro_2.png",
                lines = {
                    "Scans show valuable materials, active defense systems,",
                    "...and one (1) extremely large life sign.",
                    "The life sign is circling us. Casually.",
                }
            },
            {
                imagePath = "assets/images/episodes/ep4/ep4_intro_3.png",
                lines = {
                    "Objective: Collect salvage. Avoid the turrets.",
                    "Make friends with whatever that thing is. It looks lonely.",
                    "Also hungry. But mostly lonely.",
                }
            },
        },

        endingPanels = {
            {
                imagePath = "assets/images/episodes/ep4/ep4_ending_1.png",
                lines = {
                    "Salvage complete. We've recovered alloys...",
                    "...that predate most known civilizations.",
                    "Also, we've made a friend.",
                }
            },
            {
                imagePath = "assets/images/episodes/ep4/ep4_ending_2.png",
                lines = {
                    "The creature followed us to the edge of the debris field,",
                    "...then stopped. It made a sound. Acoustics says it might...",
                    "...have been 'goodbye.' Or 'indigestion.'",
                }
            },
            {
                imagePath = "assets/images/episodes/ep4/ep4_ending_3.png",
                lines = {
                    "Research Spec unlocked: The ancient alloys...",
                    "...have remarkable properties.",
                    "We've named them 'Chompite' in honor of our new friend.",
                }
            },
        },

        unlockCondition = "episode_3",

        bossClass = "Chomper",
        spawnConfig = {
            { waveRange = {1, 2}, weights = {
                { class = "DebrisChunk", weight = 55 },
                { class = "Asteroid", weight = 45, args = {level = 1} },
            }},
            { waveRange = {3, 4}, weights = {
                { class = "DebrisChunk", weight = 30 },
                { class = "DefenseTurret", weight = 30 },
                { class = "Asteroid", weight = 40, args = {level = {1, 2}} },
            }},
            { waveRange = {5, 7}, weights = {
                { class = "DebrisChunk", weight = 25 },
                { class = "DefenseTurret", weight = 40 },
                { class = "Asteroid", weight = 35, args = {level = {1, 3}} },
            }},
        },
    },

    [5] = {
        id = 5,
        title = "Academic Standards",
        tagline = "Peer review can be brutal. Literally.",
        startingMessage = "ATTENDANCE: MANDATORY",
        backgroundPath = "assets/images/episodes/ep5/bg_ep5.png",

        introPanels = {
            {
                imagePath = "assets/images/episodes/ep5/ep5_intro_1.png",
                lines = {
                    "Welcome to the Interspecies Research Symposium.",
                    "Today's sessions include 'Is Time Real?' and 'Tentacles: A Reappraisal.'",
                    "Attendance is mandatory.",
                }
            },
            {
                imagePath = "assets/images/episodes/ep5/ep5_intro_2.png",
                lines = {
                    "Reminder: What looks like aggression may be enthusiastic agreement.",
                    "What looks like agreement may be a prelude to aggression.",
                    "Read the room.",
                }
            },
            {
                imagePath = "assets/images/episodes/ep5/ep5_intro_3.png",
                lines = {
                    "Your job: Collect proceedings.",
                    "Facilitate exchange.",
                    "Avoid the Vorthian delegation - they debate with their ships.",
                }
            },
        },

        endingPanels = {
            {
                imagePath = "assets/images/episodes/ep5/ep5_ending_1.png",
                lines = {
                    "Conference concluded. Fourteen collaborative papers drafted.",
                    "Only three diplomatic incidents. The organizing committee...",
                    "...is calling this 'a qualified success.'",
                }
            },
            {
                imagePath = "assets/images/episodes/ep5/ep5_ending_2.png",
                lines = {
                    "The Distinguished Professor has revised their...",
                    "...opinion of our research from 'derivative' to 'merely obvious.'",
                    "We're choosing to see this as progress.",
                }
            },
            {
                imagePath = "assets/images/episodes/ep5/ep5_ending_3.png",
                lines = {
                    "Research Spec unlocked: Cross-species collaboration...",
                    "...yields unexpected insights.",
                    "Also unexpected bruises.",
                }
            },
        },

        unlockCondition = "episode_4",

        bossClass = "DistinguishedProfessor",
        spawnConfig = {
            { waveRange = {1, 2}, weights = {
                { class = "DebateDrone", weight = 60 },
                { class = "Asteroid", weight = 40, args = {level = 1} },
            }},
            { waveRange = {3, 4}, weights = {
                { class = "DebateDrone", weight = 35 },
                { class = "CitationPlatform", weight = 30 },
                { class = "Asteroid", weight = 35, args = {level = {1, 2}} },
            }},
            { waveRange = {5, 7}, weights = {
                { class = "DebateDrone", weight = 30 },
                { class = "CitationPlatform", weight = 40 },
                { class = "Asteroid", weight = 30, args = {level = {1, 3}} },
            }},
        },
    },
}

-- Get episode data by ID
function EpisodesData.get(episodeId)
    return EpisodesData[episodeId]
end

-- Get spawn config for episode, falling back to episode 1
function EpisodesData.getSpawnConfig(episodeId)
    local ep = EpisodesData[episodeId]
    if ep and ep.spawnConfig then
        return ep.spawnConfig
    end
    return EpisodesData[1].spawnConfig
end

-- Get boss class name for episode, falling back to episode 1
function EpisodesData.getBossClass(episodeId)
    local ep = EpisodesData[episodeId]
    if ep and ep.bossClass then
        return ep.bossClass
    end
    return EpisodesData[1].bossClass
end

return EpisodesData
