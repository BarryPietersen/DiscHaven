/*
	Developed By: Barry Pietersen, Z018771
	Purpose: DML Script for the Disc Haven database
	Date Created: 03/08/2018
*/

USE master;
GO

USE db_disc_haven;

-----------------------------------------------------------------
DECLARE @Albany AS BIGINT;
DECLARE @Bunbury AS BIGINT;
DECLARE @Busselton AS BIGINT;
DECLARE @Manjimup AS BIGINT;

DECLARE @Game AS BIGINT;
DECLARE @Movie AS BIGINT;
DECLARE @Music AS BIGINT;
DECLARE @Software AS BIGINT;

DECLARE @BluRay AS BIGINT;
DECLARE @CD AS BIGINT;
DECLARE @DVD AS BIGINT;
DECLARE @Vinyl AS BIGINT;

--staff---------------------
DECLARE @Ramin AS BIGINT;
DECLARE @David AS BIGINT;
DECLARE @Hannes AS BIGINT;
DECLARE @Bosch AS BIGINT;

--customers------------------
DECLARE @Barry AS BIGINT;
DECLARE @Joe AS BIGINT;

DECLARE @Sales AS BIGINT;
DECLARE @Manager AS BIGINT;
DECLARE @Admin AS BIGINT;

DECLARE @OutID AS BIGINT;
DECLARE @ErrorMessage NVARCHAR(MAX);
-----------------------------------------------------------------
--location/branch creation
INSERT INTO tblLocation ([Description], [Address], PhoneNumber, Email, City, [State], PostCode) 
VALUES ('A brief description on Disc Haven - Albany', '305 Albany Highway', '08 9842 7399','albany@dischaven.com','Albany','WA','6330');
SET @Albany = SCOPE_IDENTITY();
INSERT INTO tblLocation ([Description], [Address], PhoneNumber, Email, City, [State], PostCode) 
VALUES ('A brief description on Disc Haven - Bunbury', '64 Smith Street', '08 9842 2529','bunbury@dischaven.com','Bunbury','WA','6345');
SET @Bunbury = SCOPE_IDENTITY();
INSERT INTO tblLocation ([Description], [Address], PhoneNumber, Email, City, [State], PostCode) 
VALUES ('A brief description on Disc Haven - Busselton', '96 Amber Lane', '08 9842 2324','busselton@dischaven.com','Busselton','WA','6534');
SET @Busselton = SCOPE_IDENTITY();
INSERT INTO tblLocation ([Description], [Address], PhoneNumber, Email, City, [State], PostCode) 
VALUES ('A brief description on Disc Haven - Manjimup', '305 High Street', '08 9842 6364','Manjimup@dischaven.com','Manjimup','WA','6756');
SET @Manjimup = SCOPE_IDENTITY();

-----------------------------------------------------------------
--set initial roles
INSERT INTO tblRole(Ranking, [Name]) VALUES (1, 'Sales');
SET @Sales = SCOPE_IDENTITY();
INSERT INTO tblRole(Ranking, [Name]) VALUES (2, 'Manager');
SET @Manager = SCOPE_IDENTITY();
INSERT INTO tblRole(Ranking, [Name]) VALUES (3, 'Admin');
SET @Admin = SCOPE_IDENTITY();

-----------------------------------------------------------------
--staff creation
EXEC uspAddStaff @Ramin, @Manjimup, 'Ramin','Majidi','rm@discHaven.com','72 Corner Lane','Manjimup','WA','6756','1980-08-24','0424 565 436','A brief comment abot Ramin','ramin.jpg','raminmajidi', 'password1', 'passwordhint', 'TRUE', @ErrorMessage
EXEC uspAddStaff @David, @Manjimup, 'David','McKenzie','dm@discHaven.com','25 Arduino Drive','Manjimup','WA','6756','1980-08-24','0424 456 436','A brief comment abot David','david.jpg','davidmackenzie', 'password1', 'passwordhint', 'TRUE', @ErrorMessage
EXEC uspAddStaff @Hannes, @Busselton, 'Hannes','Bernhardt','hb@discHaven.com','72 Corner Lane','Bunbury','WA','6756','1980-08-24','0424 546 436','A brief comment abot Hannes','hannes.jpg','hannesbernhardt', 'password1', 'passwordhint', 'TRUE', @ErrorMessage
EXEC uspAddStaff @Bosch, @Bunbury, 'Peter','Bosch','pb@discHaven.com','72 Corner Lane','Busselton','WA','6756','1980-08-24','0424 566 436','A brief comment abot Peter','bosch.jpg','peterbosch', 'password1', 'passwordhint', 'TRUE', @ErrorMessage

INSERT INTO tblStaffRole (FKStaffID, FKRoleID)
VALUES (1, 3), (2, 3), (3, 2), (4, 1)

-----------------------------------------------------------------
--customer creation
EXEC uspAddCustomer @Barry, 'James', 'Smith', 'z018771@tafe.wa.edu.au', '5 Smith Street', 'Albany', 'WA', '6330', '5 Smith Street', 'Albany', 'WA', '6330', 'jsmith', 'Password1!', 'passwordhint', @ErrorMessage
EXEC uspAddCustomer @Joe, 'Joe', 'Bloggs', 'joebloggs@tafe.wa.edu.au', '5 Smith Road', 'Albany', 'WA', '6330', '32 Corner Strres', 'Albany', 'WA', '6330', 'joebloggs007', 'Password1!', 'passwordhint', @ErrorMessage

EXEC uspAddSecurityQA @OutID, 1, 'hello, how are you today?', 'very well, thankyou!', @ErrorMessage
EXEC uspAddSecurityQA @OutID, 1, 'what kind of secret question is this?', 'a perfect question for this answer', @ErrorMessage
EXEC uspAddSecurityQA @OutID, 1, 'for a third secret question, what kind of answer would you choose?', 'literally anything!', @ErrorMessage

EXEC uspAddSecurityQA @OutID, 2, 'hello, how are you today?', 'very well, thankyou!', @ErrorMessage
EXEC uspAddSecurityQA @OutID, 2, 'what kind of secret question is this?', 'a perfect question for this answer', @ErrorMessage
EXEC uspAddSecurityQA @OutID, 2, 'for a third secret question, what kind of answer would you choose?', 'literally anything!', @ErrorMessage

-----------------------------------------------------------------------------------------------------------------------------------------------------------------
--mediatypes
INSERT INTO tblMediaType ([Description]) VALUES ('Blu Ray');
SET @BluRay = SCOPE_IDENTITY();
INSERT INTO tblMediaType ([Description]) VALUES ('DVD');
SET @DVD = SCOPE_IDENTITY();
INSERT INTO tblMediaType ([Description]) VALUES ('CD');
SET @CD = SCOPE_IDENTITY();
INSERT INTO tblMediaType ([Description]) VALUES ('Vinyl');
SET @Vinyl = SCOPE_IDENTITY();

------------------------------------------------------------------------------
--categories
INSERT INTO tblCategory([Description])VALUES('Movie');
SET @Movie = SCOPE_IDENTITY();
INSERT INTO tblCategory([Description])VALUES('Music');
SET @Music = SCOPE_IDENTITY();
INSERT INTO tblCategory([Description])VALUES('Game');
SET @Game = SCOPE_IDENTITY();
INSERT INTO tblCategory([Description])VALUES('Software');
SET @Software = SCOPE_IDENTITY();

--movie titles----------------------------------------------------------------
INSERT INTO tblTitle (FKCategoryID, [Name], [Description])
VALUES (@Movie ,'August Rush', 'a movie description about August Rush');--1
INSERT INTO tblTitle (FKCategoryID, [Name], [Description])
VALUES (@Movie ,'Avengers', 'a movie description about Avengers');--2
INSERT INTO tblTitle (FKCategoryID, [Name], [Description])
VALUES (@Movie ,'Divergent', 'a movie description about Divergent');--3
INSERT INTO tblTitle (FKCategoryID, [Name], [Description])
VALUES (@Movie ,'Fight Club', 'a movie description about Fight Club');--4
INSERT INTO tblTitle (FKCategoryID, [Name], [Description])
VALUES (@Movie ,'I Am Legend', 'a movie description about I Am Legend');--5
INSERT INTO tblTitle (FKCategoryID, [Name], [Description])
VALUES (@Movie ,'Matrix', 'a movie description about Matrix');--6
INSERT INTO tblTitle (FKCategoryID, [Name], [Description])
VALUES (@Movie ,'Moonlight', 'a movie description about Moonlight');--7
INSERT INTO tblTitle (FKCategoryID, [Name], [Description])
VALUES (@Movie ,'Ted', 'a movie description about Ted');--8

--music titles-----------------------------------------------------------------
INSERT INTO tblTitle (FKCategoryID, [Name], [Description])
VALUES (@Music ,'Jay Z The Black Album', 'a music description about');--9
INSERT INTO tblTitle (FKCategoryID, [Name], [Description])
VALUES (@Music ,'Drake Views', 'a music description about');--10
INSERT INTO tblTitle (FKCategoryID, [Name], [Description])
VALUES (@Music ,'Cardi B Privacy', 'a music description about');--11
INSERT INTO tblTitle (FKCategoryID, [Name], [Description])
VALUES (@Music ,'Ed Sheeran Divide', 'a music description about');--12
INSERT INTO tblTitle (FKCategoryID, [Name], [Description])
VALUES (@Music ,'Maroon 5 Songs About Jane', 'a music description about');--13
INSERT INTO tblTitle (FKCategoryID, [Name], [Description])
VALUES (@Music ,'Bruno Mars Doo-Wops And Hooligans', 'a music description about');--14
INSERT INTO tblTitle (FKCategoryID, [Name], [Description])
VALUES (@Music ,'Flume Live At Red Rocks', 'a music description about');--15
INSERT INTO tblTitle (FKCategoryID, [Name], [Description])
VALUES (@Music ,'Hilltop Hoods State of the Art', 'a music description about');--16

--game titles---------------------------------------------------------------------
INSERT INTO tblTitle (FKCategoryID, [Name], [Description])
VALUES (@Game ,'Half-Life Game of the Year Edition', 'a game description about');--17
INSERT INTO tblTitle (FKCategoryID, [Name], [Description])
VALUES (@Game ,'The Legend of Zelda', 'a game description about');--18
INSERT INTO tblTitle (FKCategoryID, [Name], [Description])
VALUES (@Game ,'Super Mario Cart', 'a game description about');--19
INSERT INTO tblTitle (FKCategoryID, [Name], [Description])
VALUES (@Game ,'Portal', 'a game description about');--20
INSERT INTO tblTitle (FKCategoryID, [Name], [Description])
VALUES (@Game ,'Mass Effect 3', 'a game description about');--21
INSERT INTO tblTitle (FKCategoryID, [Name], [Description])
VALUES (@Game ,'Age of Empires 2 The Age of the Kings', 'a game description about');--22
INSERT INTO tblTitle (FKCategoryID, [Name], [Description])
VALUES (@Game ,'GTA 5', 'a game description about');--23
INSERT INTO tblTitle (FKCategoryID, [Name], [Description])
VALUES (@Game ,'Fallout', 'a game description about');--24

--software titles---------------------------------------------------------------------
INSERT INTO tblTitle (FKCategoryID, [Name], [Description])
VALUES (@Software ,'Windows 10 Home', 'a description about Windows 10');--25
INSERT INTO tblTitle (FKCategoryID, [Name], [Description])
VALUES (@Software ,'Microsoft Office 365', 'a description about Office 365');--26
INSERT INTO tblTitle (FKCategoryID, [Name], [Description])
VALUES (@Software ,'Xero', 'Small Business Australian payroll software for companies with up to 5 Employees');--27
INSERT INTO tblTitle (FKCategoryID, [Name], [Description])
VALUES (@Software ,'PowerDirector Ultimate', 'the best video editor of the year, includes all the powerful video editing tools for high quality results');--28
INSERT INTO tblTitle (FKCategoryID, [Name], [Description])
VALUES (@Software ,'BitDefender Total Security', 'Bitdefender Total Security 2019 works against all threats – from viruses, worms and Trojans, to ransomware, zero-day exploits');--29
INSERT INTO tblTitle (FKCategoryID, [Name], [Description])
VALUES (@Software ,'McAfee Total Protection', 'Premium antivirus, identity and privacy protection for your PCs, Macs, smartphones, and tablets');--30
INSERT INTO tblTitle (FKCategoryID, [Name], [Description])
VALUES (@Software ,'Microsoft Visual Studio', 'Develop your applications using a powerful IDE');--31
INSERT INTO tblTitle (FKCategoryID, [Name], [Description])
VALUES (@Software ,'Architect 3D Ultimate', 'The ultimate solution to help you design your dream project!');--32

INSERT INTO tblTitle (FKCategoryID, [Name], [Description])
VALUES (@Music ,'My Chemical Romance', 'a music description about');--33
INSERT INTO tblTitle (FKCategoryID, [Name], [Description])
VALUES (@Music ,'The Beatles', 'a music description about');--34
INSERT INTO tblTitle (FKCategoryID, [Name], [Description])
VALUES (@Music ,'Angus Stone', 'a music description about');--35
INSERT INTO tblTitle (FKCategoryID, [Name], [Description])
VALUES (@Music ,'Blink 182', 'a music description about');--36

EXEC uspCreateTitle @OutID, @Movie, '', 'Star Trek', @ErrorMessage--37
EXEC uspCreateTitle @OutID, @Movie, '', 'Casino', @ErrorMessage--38
EXEC uspCreateTitle @OutID, @Movie, '', 'Good Fellas', @ErrorMessage--39
EXEC uspCreateTitle @OutID, @Movie, '', 'American Hustle', @ErrorMessage--40
EXEC uspCreateTitle @OutID, @Music, '', 'Rodriguez', @ErrorMessage--41

--movie products ---------------------------------------------------------------------------------------------------------------
EXEC uspCreateProduct @OutID, 1 , @DVD, 'August Rush', 'An infant secretly given away by Lyla''s father has grown into an unusually gifted child who hears music all around him and can turn the rustling of wind through a wheat field into a beautiful symphony with himself at its center, the composer and conductor. He holds an unwavering belief that his parents are alive and want him as much as he wants them. Determined to search for them, he makes his way to New York City. ', 25, .11, '2000-01-09', 'TRUE', 'augustrush.jpg', @ErrorMessage
EXEC uspCreateProduct @OutID, 2 , @BluRay, 'Avengers', 'Marvel Studios presents Marvel''s The Avengers-the Super Hero team up of a lifetime, featuring iconic Marvel Super Heroes Iron Man, The Incredible Hulk, Thor, Captain America, Hawkeye and Black Widow. When an unexpected enemy emerges that threatens global safety and security, Nick Fury, Director of the international peacekeeping agency known as S.H.I.E.L.D., finds himself in need of a team to pull the world back from the brink of disaster. Spanning the globe, a daring recruitment effort begins. ', 25, .13, '2000-01-09', 'TRUE', 'avengers.jpg', @ErrorMessage
EXEC uspCreateProduct @OutID, 3 , @BluRay, 'Divergent', 'DIVERGENT is a thrilling action-adventure film set in a world where people are divided into distinct factions based on human virtues. Tris Prior (Shailene Woodley) is warned she is Divergent and will never fit into any one group. When she discovers a conspiracy by a faction leader (Kate Winslet) to destroy all Divergents, Tris must learn to trust in the mysterious Four (Theo James) and together they must find out what makes being Divergent so dangerous before it''s too late. Based on the best-selling book series by Veronica Roth.', 25, .05, '2000-01-09', 'TRUE', 'divergent.jpg', @ErrorMessage
EXEC uspCreateProduct @OutID, 4 , @BluRay, 'Fight Club', 'In this darkly comic drama, Edward Norton stars as a depressed young man (named in the credits only as "Narrator") who has become a small cog in the world of big business. He doesn''t like his work and gets no sense of reward from it, attempting instead to drown his sorrows by putting together the "perfect" apartment.t', 25, .03, '2000-01-09', 'TRUE', 'fightclub.jpg', @ErrorMessage
EXEC uspCreateProduct @OutID, 5 , @DVD, 'I Am Legend', 'Adapted from acclaimed author Richard Matheson''s influential novelette of the same name, Constantine director Francis Lawrence''s I Am Legend follows the last man on Earth as he struggles to survive while fending off the infected survivors of a devastating vampiric plague. A brilliant scientist who raced to discover a cure for the man-made virus as humanity came crumbling down all around him, Robert Neville (Will Smith) was inexplicably immune to the highly contagious superbug.', 25, .1, '2000-01-09', 'TRUE', 'iamlegend.png', @ErrorMessage
EXEC uspCreateProduct @OutID, 6 , @DVD, 'Matrix', 'What if virtual reality wasn''t just for fun, but was being used to imprison you? That''s the dilemma that faces mild-mannered computer jockey Thomas Anderson (Keanu Reeves) in The Matrix. It''s the year 1999, and Anderson (hacker alias: Neo) works in a cubicle, manning a computer and doing a little hacking on the side. It''s through this latter activity that Thomas makes the acquaintance of Morpheus (Laurence Fishburne), who has some interesting news for Mr. Anderson -- none of what''s going on around him is real. ', 25, .14, '2000-01-09', 'TRUE', 'matrix.png', @ErrorMessage
EXEC uspCreateProduct @OutID, 7 , @DVD, 'Moonlight', 'The tender, heartbreaking story of a young man''s struggle to find himself, told across three defining chapters in his life as he experiences the ecstasy, pain, and beauty of falling in love, while grappling with his own sexuality.', 25, .3, '2000-01-09', 'TRUE', 'moonlight.jpeg', @ErrorMessage
EXEC uspCreateProduct @OutID, 8 , @BluRay, 'Ted', 'Family Guy creator Seth MacFarlane brings his boundary-pushing brand of humor to the big screen for the first time as writer, director and voice star of Ted. In the live action/CG-animated comedy, he tells the story of John Bennett (Mark Wahlberg), a grown man who must deal with the cherished teddy bear who came to life as the result of a childhood wish...and has refused to leave his side ever since.', 25, .1, '2000-01-09', 'TRUE', 'ted.jpg', @ErrorMessage

--music products-------------------------------------------------------------------------------------------------------------------
EXEC uspCreateProduct @OutID, 9 , @CD, 'Jay Z The Black Album', 'If The Black Album is truly Jay-Z''s last statement before retirement, he at least goes out near the top of his game. While it probably won''t be remembered as his best album, The Black Album is his most personal to date and features some of his most compelling writing.', 29, .08, '2000-01-09', 'TRUE', 'jayztheblackalbum.jpg', @ErrorMessage
EXEC uspCreateProduct @OutID, 10 , @CD, 'Drake Views', 'Views is the fourth studio album by Canadian rapper Drake. It was released on April 29, 2016, by Young Money Entertainment, Cash Money Records and Republic Records.', 29, .08, '2000-01-09', 'TRUE', 'drakeviews.jpg', @ErrorMessage
EXEC uspCreateProduct @OutID, 11 , @CD, 'Cardi B Privacy', 'Invasion of Privacy is the debut studio album by American rapper Cardi B. It was released on April 5, 2018, by Atlantic Records. Primarily a hip hop album, Invasion of Privacy also comprises trap and Latin.', 29, .08, '2000-01-09', 'TRUE', 'cardibprivacy.jpg', @ErrorMessage
EXEC uspCreateProduct @OutID, 12 , @CD, 'Ed Sheeran Divide', '÷ is the third studio album by English singer-songwriter Ed Sheeran. It was released on 3 March 2017 through Asylum Records and Atlantic Records. "Castle on the Hill" and "Shape of You" were released as the album''s lead singles on 6 January 2017.', 29, .08, '2000-01-09', 'TRUE', 'edsheerandivide.jpg', @ErrorMessage
EXEC uspCreateProduct @OutID, 13 , @CD, 'Maroon 5 Songs About Jane', 'Songs About Jane is the debut studio album by American pop rock band Maroon 5. It was released on June 25, 2002 by Octone and J Records.', 29, .09, '2000-01-09', 'TRUE', 'maroon5songsaboutjane.jpg', @ErrorMessage
EXEC uspCreateProduct @OutID, 14 , @CD, 'Bruno Mars Doo-Wops And Hooligans', 'Doo-Wops & Hooligans is the debut studio album by American singer-songwriter Bruno Mars, which was released on October 4, 2010 by Atlantic and Elektra Records.', 29, .1, '2000-01-09', 'TRUE', 'brunomarsdoowopsandhooligans.jpg', @ErrorMessage
EXEC uspCreateProduct @OutID, 15 , @CD, 'Flume Live At Red Rocks', 'Harley Edward Streten, known professionally as Flume, is an Australian record producer, musician and DJ. His self-titled debut studio album Flume', 29, .2, '2000-01-09', 'TRUE', 'flumeliveatredrocks.png', @ErrorMessage
EXEC uspCreateProduct @OutID, 16 , @CD, 'Hilltop Hoods State of the Art', 'State of the Art is the fifth studio album released by Australian hip hop trio, Hilltop Hoods, on 12 June 2009.', 29, .3, '2000-01-09', 'TRUE', 'hilltophoodsstateoftheart.png', @ErrorMessage

--game products----------------------------------------------------------------------------------------------------------------------
EXEC uspCreateProduct @OutID, 17 , @CD, 'Half-Life Game of the Year Edition', 'Winning over 50 Game of the Year awards and named best game of all time by PC Gamer magazine, Half-Life is an extraordinary achievement that established the benchmark for future games in the genre.', 35, .11, '2000-01-09', 'TRUE', 'halflifegameoftheyearedition.jpg', @ErrorMessage
EXEC uspCreateProduct @OutID, 18 , @CD, 'The Legend of Zelda', 'The Legend of Zelda is a action-adventure video-game series created by Japanese game designers Shigeru Miyamoto and Takashi Tezuka. It is primarily developed and published by Nintendo, although some portable installments and re-releases have been outsourced to Capcom, Vanpool and Grezzo.', 35, .11, '2000-01-09', 'TRUE', 'thelegendofzelda.jpg', @ErrorMessage
EXEC uspCreateProduct @OutID, 19 , @CD, 'Super Mario Cart', 'Super Mario Kart is a 1992 kart racing video game developed and published by Nintendo for the Super Nintendo Entertainment System video game console. The first game of the Mario Kart series, it was released in Japan and North America in 1992, and in Europe the following year.', 35, .11, '2000-01-09', 'TRUE', 'supermariocart.jpg', @ErrorMessage
EXEC uspCreateProduct @OutID, 20 , @CD, 'Portal', 'Portal is a puzzle-platform video game developed and published by Valve Corporation. It was released in a bundle package called The Orange Box for Microsoft Windows, Xbox 360 and PlayStation 3 in 2007. The game has since been ported to other systems, including OS X, Linux, and Android.', 35, .11, '2000-01-09', 'TRUE', 'portalstillalive.jpg', @ErrorMessage
EXEC uspCreateProduct @OutID, 21 , @CD, 'Mass Effect 3', 'Mass Effect 3 is an action role-playing video game developed by BioWare and published by Electronic Arts. It was released for Microsoft Windows, Xbox 360, and PlayStation 3 on March 6, 2012. A Wii U version of the game titled Mass Effect 3: Special Edition was later released on November 18, 2012.', 35, .11, '2000-01-09', 'TRUE', 'masseffect3.png', @ErrorMessage
EXEC uspCreateProduct @OutID, 22 , @CD, 'Age of Empires 2 The Age of the Kings', 'Age of Empires II: The Age of Kings is a real-time strategy video game developed by Ensemble Studios and published by Microsoft. Released in 1999 for Microsoft Windows and Macintosh, it is the second game in the Age of Empires series. An expansion, The Conquerors, was released in 2000.', 35, .11, '2000-01-09', 'TRUE', 'ageofempires2theageofkings.jpg', @ErrorMessage
EXEC uspCreateProduct @OutID, 23 , @CD, 'GTA 5', 'Grand Theft Auto V is an action-adventure video game developed by Rockstar North and published by Rockstar Games. It was released in September 2013 for PlayStation 3 and Xbox 360, in November 2014 for PlayStation 4 and Xbox One, and in April 2015 for Microsoft Windows.', 35, .11, '2000-01-09', 'TRUE', 'grandtheftauto5V.jpg', @ErrorMessage
EXEC uspCreateProduct @OutID, 24 , @CD, 'Fallout', 'Released in 1997, Fallout takes place in a post-apocalyptic Southern California, beginning in the year 2161. The protagonist, referred to as the Vault Dweller, is tasked with recovering a water chip in the Wasteland to replace the broken one in their underground shelter home, Vault 13.', 35, .11, '2000-01-09', 'TRUE', 'fallout.jpg', @ErrorMessage

--software products-------------------------------------------------------------------------------------------------------------------
EXEC uspCreateProduct @OutID, 25 , @CD, 'Windows 10 Home', 'Windows 10 is a series of personal computer operating systems produced by Microsoft as part of its Windows NT family of operating systems. It is the successor to Windows 8.1, and was released to manufacturing on July 15, 2015, and to retail on July 29, 2015.', 280, .18, '2000-01-09', 'TRUE', 'windows10home.jpg', @ErrorMessage
EXEC uspCreateProduct @OutID, 26 , @CD, 'Microsoft Office 365', 'Office 365 is a line of subscription services offered by Microsoft, as part of the Microsoft Office product line. The brand encompasses plans that allow use of the Microsoft Office software suite over the life of the subscription, as well as cloud-based software as a service products for business environments, such as hosted Exchange Server, Skype for Business Server, and SharePoint among others.', 265, .18, '2000-01-09', 'TRUE', 'office365.jpg', @ErrorMessage
EXEC uspCreateProduct @OutID, 27 , @CD, 'Xero', 'Xero is a New Zealand domiciled public software company that offers a cloud-based accounting software platform for small and medium-sized businesses. The company has offices in New Zealand, Australia, the United Kingdom, the United States, Canada, Asia and South Africa.', 350, .2, '2000-01-09', 'TRUE', 'xero.jpg', @ErrorMessage
EXEC uspCreateProduct @OutID, 28 , @CD, 'PowerDirector Ultimate', 'the best video editor of the year, includes all the powerful video editing tools for high quality results', 295, .1, '2000-01-09', 'TRUE', 'powerdirector.png', @ErrorMessage
EXEC uspCreateProduct @OutID, 29 , @CD, 'BitDefender Total Security', 'Bitdefender Total Security 2019 works against all threats – from viruses, worms and Trojans, to ransomware, zero-day exploits', 295, .21, '2000-01-09', 'TRUE', 'bitdefender.jpg', @ErrorMessage
EXEC uspCreateProduct @OutID, 30 , @CD, 'McAfee Total Protection', 'Premium antivirus, identity and privacy protection for your PCs, Macs, smartphones, and tablets', 60, .23, '2000-01-09', 'TRUE', 'mcafeetotalprotection.jpg', @ErrorMessage
EXEC uspCreateProduct @OutID, 31 , @CD, 'Microsoft Visual Studio', 'Microsoft Visual Studio is an integrated development environment from Microsoft. It is used to develop computer programs, as well as websites, web apps, web services and mobile apps.', 300, .12, '2000-01-09', 'TRUE', 'visualstudio.jpg', @ErrorMessage
EXEC uspCreateProduct @OutID, 32 , @CD, 'Architect 3D Ultimate', 'The ultimate solution to help you design your dream project!', 200, .14, '2000-01-09', 'TRUE', 'architect3d.jpg', @ErrorMessage

--extra products-------------------------------------------------------------------------------------------------------------------
EXEC uspCreateProduct @OutID, 33 , @CD, 'My Chemical Romance - Three Cheers For Sweet Revenge', 'Three Cheers for Sweet Revenge is the second studio album by American rock band My Chemical Romance, released on June 8, 2004 by Reprise Records', 35, .08, '2004-08-06', 'TRUE', 'threecheers.jpg', @ErrorMessage
EXEC uspCreateProduct @OutID, 34 , @CD, 'The Beatles - Abbey Road', 'Abbey Road is a rock album that incorporates genres such as blues, pop, and progressive rock,[2] and it makes prominent use of the Moog synthesizer and the Leslie speaker', 33, .08, '1968-01-09', 'TRUE', 'abbeyroad.jpg', @ErrorMessage
EXEC uspCreateProduct @OutID, 34 , @CD, 'The Beatles - Sgt. Peppers Lonely Hearts Club Band ', 'Sgt. Peppers Lonely Hearts Club Band is the eighth studio album by the English rock band the Beatles. Released on 26 May 1967 in the United Kingdom', 34, .08, '1967-01-09', 'TRUE', 'sgtpepper.jpg', @ErrorMessage
EXEC uspCreateProduct @OutID, 35 , @CD, 'Angus Stone - Lady of the Sunshine', 'The album reached the top 50 on the ARIA Albums Chart.[7] One of his tracks, "Big Jet Plane", from Smoking Gun was later re-recorded by Angus & Julia Stone and released by the duo as a single in May 2010.', 40, .08, '2000-01-09', 'TRUE', 'ladyofthesunshine.jpg', @ErrorMessage
EXEC uspCreateProduct @OutID, 36 , @CD, 'Blink 182 - Take Off Your Pants and Jacket', 'The fourth studio album by American rock band Blink-182, released on June 12, 2001 by MCA Records. The band had spent much of the previous year traveling and supporting their previous album Enema of the State (1999), which launched their mainstream career', 29, .08, '2001-06-12', 'TRUE', 'takeoffpants.jpg', @ErrorMessage

EXEC uspCreateProduct @OutID, 37 , @DVD, 'Star Trek Generations', 'Star Trek Generations is a 1994 American science fiction film directed by David Carson and based on the franchise of the same name created by Gene Roddenberry.', 25, .08, '1994-11-18', 'TRUE', 'stargenerations.png', @ErrorMessage
EXEC uspCreateProduct @OutID, 37 , @DVD, 'Star Trek: First Contact', 'Star Trek: First Contact is a 1996 American science fiction film directed by Jonathan Frakes (in his cinematic directorial debut), and based on the franchise of the same name created by Gene Roddenberry.', 25, .10, '1996-11-22', 'TRUE', 'starfirstcontact.jpg', @ErrorMessage
EXEC uspCreateProduct @OutID, 37 , @DVD, 'Star Trek: Nemesis', 'Star Trek: Nemesis is a 2002 American science fiction film directed by Stuart Baird and based on the franchise of the same name created by Gene Roddenberry.', 25, .03, '1998-12-11', 'TRUE', 'starnemesis.jpg', @ErrorMessage
EXEC uspCreateProduct @OutID, 38 , @DVD, 'Casino', 'Casino is a 1995 American epic crime film directed by Martin Scorsese, starring Robert De Niro, Sharon Stone, and Joe Pesci. It is based on the nonfiction book Casino: Love and Honor in Las Vegas[4] by Nicholas Pileggi, who also co-wrote the screenplay for the film with Scorsese.', 45, .11, '1995-01-09', 'TRUE', 'casino.jpg', @ErrorMessage
EXEC uspCreateProduct @OutID, 39 , @DVD, 'Goodfellas', 'Goodfellas (stylized GoodFellas) is a 1990 American crime film directed by Martin Scorsese. It is an adaptation of the 1985 non-fiction book Wiseguy by Nicholas Pileggi, who co-wrote the screenplay with Scorsese. The film narrates the rise and fall of mob associate Henry Hill and his friends and family from 1955 to 1980.', 40, .10, '1990-01-09', 'TRUE', 'goodfellas.jpg', @ErrorMessage
EXEC uspCreateProduct @OutID, 40 , @DVD, 'Amercan Hustle', 'American Hustle is a 2013 American black comedy-crime film directed by David O. Russell. It was written by Eric Warren Singer and Russell, inspired by the FBI ABSCAM operation of the late 1970s and early 1980s.', 36, .11, '2013-12-08', 'TRUE', 'americanhustle.jpg', @ErrorMessage
EXEC uspCreateProduct @OutID, 41 , @Vinyl, 'Rodriguez - Cold Fact', 'Cold Fact is the debut album from American singer-songwriter Rodriguez. It was released in the United States on the Sussex label in March 1970. The album sold very poorly in the United States (Rodriguez was himself an unknown in the US), but managed to sell well in both South Africa and Australia, with Rodriguez touring Australia in 1979.', 40, .08, '1970-03-08', 'TRUE', 'coldfact.jpg', @ErrorMessage
EXEC uspCreateProduct @OutID, 41 , @Vinyl, 'Rodriguez - Coming From Reality', 'Coming from Reality is the second and final studio album to date from American singer and songwriter Rodriguez, originally released by Sussex Records in 1971. It was later released in South Africa in 1976 with the alternate title After the Fact.', 40, .08, '1971-11-08', 'TRUE', 'comingfromreality.jpg', @ErrorMessage

--Coming from Reality is the second and final studio album to date from American singer and songwriter Rodriguez, originally released by Sussex Records in 1971. It was later released in South Africa in 1976 with the alternate title After the Fact.

--cart items------------------------------------------
EXEC uspAddToCart @OutID, 15, 1, 2, @ErrorMessage;
EXEC uspAddToCart @OutID, 13, 1, 1, @ErrorMessage;
EXEC uspAddToCart @OutID, 11, 1, 4, @ErrorMessage;
EXEC uspAddToCart @OutID, 1, 1, 1, @ErrorMessage;


--------------------------------------------------------------------------------------------------------------------------
EXEC uspAddSearchValue @OutID, 3, 'xero', @ErrorMessage
EXEC uspAddSearchValue @OutID, 3, 'visual', @ErrorMessage
EXEC uspAddSearchValue @OutID, 3, 'hilltop', @ErrorMessage
EXEC uspAddSearchValue @OutID, 3, 'portal', @ErrorMessage
EXEC uspAddSearchValue @OutID, 3, 'mass effect', @ErrorMessage
EXEC uspAddSearchValue @OutID, 3, 'Ted', @ErrorMessage

-----------------------------------------------------------------
--STATUS CODE
INSERT INTO tblOrderStatus(StatusCode) 
VALUES (1), (2), (3), (4);

INSERT INTO tblConfiguration(NumPageItemsToDisplay, SlideShowDelaySec, GST)
VALUES(12, 7, 3);

USE master;