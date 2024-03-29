-- C2M2 sample data

-- countries
INSERT INTO countries (id, name) VALUES
  (1, 'United States'),
  (2, 'Japan'),
  (3, 'United Kingdom');

-- media_types
INSERT INTO media_types (id, name) VALUES
  (1, 'Feature Film - Narrative'),
  (2, 'Feature Film - Documentary/Other'),
  (3, 'Short Film - Narrative'),
  (4, 'Short Film - Documentary/Other'),
  (5, 'Silent Film - Feature, Short, or Photoplay'),
  (6, 'Serial Series - Narrative'),
  (7, 'Serial Series - Documentary/Other'),
  (8, 'Serial Series - Information/Education'),
  (9, 'Video Game'),
  (10, 'Radio or Podcast');

-- material_formats
INSERT INTO material_formats (id, name) VALUES
  (1, 'Manuscript Scores'),
  (2, 'Printed Scores and Parts'),
  (3, 'Short Scores'),
  (4, 'Sketches'),
  (5, 'Published Scores or Collections'),
  (6, 'Cue Sheets'),
  (7, 'Working Notes'),
  (8, 'Recordings'),
  (9, 'Contracts'),
  (10, 'Personal Papers and Other Items');

-- cataloguers
INSERT INTO catalogers (id, name, email) VALUES
  (1, 'Michael W. Harris', 'michael.w.harris@colorado.edu'),
  (2, 'Sienna M. Wood', 'sienna.wood@colorado.edu');

-- works
INSERT INTO works (id, title, year, country_id, media_type_id, material_format_id, cataloger_id, citation_source)
VALUES
  ('01012016', 'Silverado (Motion picture)', 1985, 1, 1, 2, 1, 'Copy Owned'),
  ('01022016', 'Matrix (Motion picture)', 1999, 1, 1, 2, 1, 'Copy Owned'),
  ('01032016', 'Batman (Motion picture : 1989)', 1989, 1, 1, 2, 1,
   'Copy Owned'),
  ('01042016', 'Edward Scissorhands (Motion picture)', 1990, 1, 1, 2, 1,
   'Copy Owned'),
  ('01052016', 'Willow (Motion picture)', 1988, 1, 1, 2, 2, 'Copy Owned'),
  ('01062016', 'Back to the future (Motion picture)', 1985, 1, 1, 2, 1,
   'Copy Owned'),
  ('01082016', 'Rashōmon (Motion picture)', 1950, 2, 1, 1, 1, 'Copy Owned');

INSERT INTO works (id, title, year, country_id, media_type_id, finding_aid_link, material_format_id, cataloger_id, citation_source)
VALUES
  ('01102016', 'Lawrence of Arabia (Motion picture)', 1962, 3, 1,
   'http://www.uwyo.edu/ahc/_files/pdffa/03261.pdf', 1, 1,
   'Institutional Website'),
  ('01092016', 'Goonies', 1985, 1, 1,
   'http://www.colorado.edu/amrc/sites/default/files/attached-files/AMRC-Grusin.pdf',
   1, 1, 'Institutional Contact');

INSERT INTO works (id, title, secondary_title, year, country_id, media_type_id, material_format_id, cataloger_id, citation_source)
VALUES
  ('01072016', 'Shichinin no samurai (Motion picture)', 'Seven Samurai', 1954,
   2, 1, 1, 1, 'Email with Repository');

-- repositories
INSERT INTO repositories (id, name, location, website) VALUES
  (100000, 'Michael W. Harris Family Archive and Arcade Fun Complex',
   'Boulder, CO', 'http://www.michaelwharris.net/'),
  (100001, 'American Music Research Center at CU Boulder', 'Boulder, CO',
   'http://www.colorado.edu/amrc/'),
  (100002, 'American Heritage Center at University of Wyoming', 'Laramie, WY',
   'http://www.uwyo.edu/ahc/'),
  (100003, 'Archives of Modern Japanese Music at Meiji Gakuin University',
   'Tokyo, Japan', 'http://www.meijigakuin.ac.jp/library/amjm/en/');

-- collections
INSERT INTO collections (id, name, repository_id) VALUES
  (1, 'Michael W. Harris Collection', 100000),
  (2, 'Fumio Hayasaka Collection', 100003),
  (3, 'Maurice Jarre papers', 100002),
  (4, 'Dave Grusin manuscripts', 100001);

-- work_collection
INSERT INTO work_collection (work_id, collection_id) VALUES
  (01012016, 1),
  (01022016, 1),
  (01032016, 1),
  (01042016, 1),
  (01052016, 1),
  (01062016, 1),
  (01072016, 2),
  (01082016, 2),
  (01092016, 4),
  (01102016, 3);

-- composers
INSERT INTO composers (id, name, imdb_link) VALUES
  (200000, 'Broughton, Bruce, 1945-', 'http://www.imdb.com/name/nm0005976/'),
  (200001, 'Davis, Don, 1957-', 'http://www.imdb.com/name/nm0204485/'),
  (200002, 'Elfman, Danny', 'http://www.imdb.com/name/nm0000384/'),
  (200003, 'Horner, James', 'http://www.imdb.com/name/nm0000035/'),
  (200004, 'Silvestri, Alan', 'http://www.imdb.com/name/nm0006293/'),
  (200005, 'Hayasaka, Fumio, 1914-1955',
   'http://www.imdb.com/name/nm0370593/'),
  (200006, 'Grusin, Dave', 'http://www.imdb.com/name/nm0006115/'),
  (200007, 'Jarre, Maurice', 'http://www.imdb.com/name/nm0003574/');

-- work_composer
INSERT INTO work_composer (composer_id, work_id) VALUES
  (200000, 01012016),
  (200001, 01022016),
  (200002, 01032016),
  (200002, 01042016),
  (200003, 01052016),
  (200004, 01062016),
  (200005, 01072016),
  (200005, 01082016),
  (200006, 01092016),
  (200007, 01102016);

-- directors
INSERT INTO directors (id, name, imdb_link) VALUES
  (300000, 'Kasdan, Lawrence, 1949-', 'http://www.imdb.com/name/nm0001410/'),
  (300001, 'Wachowski, Lilly, 1967-', 'http://www.imdb.com/name/nm0905152/'),
  (300002, 'Wachowski, Lana, 1965-', 'http://www.imdb.com/name/nm0905154/'),
  (300003, 'Burton, Tim, 1958-', 'http://www.imdb.com/name/nm0000318/'),
  (300004, 'Howard, Ron, 1954-', 'http://www.imdb.com/name/nm0000165/'),
  (300005, 'Zemeckis, Robert, 1952-', 'http://www.imdb.com/name/nm0000709/'),
  (300006, 'Kurosawa, Akira, 1910-1998',
   'http://www.imdb.com/name/nm0000041/'),
  (300007, 'Donner, Richard', 'http://www.imdb.com/name/nm0001149/'),
  (300008, 'Lean, David, 1908-1991', 'http://www.imdb.com/name/nm0000180/');

-- work_director
INSERT INTO work_director (director_id, work_id) VALUES
  (300000, 01012016),
  (300001, 01022016),
  (300002, 01022016),
  (300003, 01032016),
  (300003, 01042016),
  (300004, 01052016),
  (300005, 01062016),
  (300006, 01072016),
  (300006, 01082016),
  (300007, 01092016),
  (300008, 01102016);

-- production_companies
INSERT INTO production_companies (id, name, contact_info) VALUES
  (400000, 'Columbia Pictures Corporation', 'http://www.sonypictures.com/'),
  (400002, 'Warner Bros. Pictures (1969- )', 'http://www.warnerbros.com/'),
  (400003, 'Village Roadshow Pictures', 'http://vreg.com/'),
  (400008, 'Twentieth Century-Fox Film Corporation',
   'http://www.foxmovies.com/'),
  (400009, 'Metro-Goldwyn-Mayer', 'http://www.mgm.com/'),
  (400010, 'Lucasfilm, Ltd.', 'http://lucasfilm.com/'),
  (400011, 'Imagine Entertainment (Firm)',
   'http://www.imagine-entertainment.com/'),
  (400012, 'Universal Pictures Company',
   'https://www.universalpictures.com/'),
  (400013, 'Amblin Entertainment (Firm)', 'http://www.amblinpartners.com/'),
  (400015, 'Tōhō Kabushiki Kaisha', 'http://www.tohoeiga.jp/eng/aisatu.html');

INSERT INTO production_companies (id, name) VALUES
  (400001, 'Columbia-Delphi IV Productions'),
  (400004, 'Groucho II Film Partnership'),
  (400005, 'Silver Pictures'),
  (400006, 'Guber-Peters Company'),
  (400007, 'PolyGram Filmed Entertainment (Firm)'),
  (400014, 'U-Drive Productions'),
  (400016, 'Daiei Kabushiki Kaisha (1945-1971)'),
  (400017, 'Horizon Pictures (G.B.)');

-- work_production_company
INSERT INTO work_production_company (production_company_id, work_id) VALUES
  (400000, 01012016),
  (400001, 01012016),
  (400002, 01022016),
  (400003, 01022016),
  (400004, 01022016),
  (400005, 01022016),
  (400002, 01032016),
  (400006, 01032016),
  (400007, 01032016),
  (400008, 01042016),
  (400009, 01052016),
  (400010, 01052016),
  (400011, 01052016),
  (400012, 01062016),
  (400013, 01062016),
  (400014, 01062016),
  (400015, 01072016),
  (400016, 01082016),
  (400002, 01092016),
  (400013, 01092016),
  (400017, 01102016);

-- publishers
INSERT INTO publishers (id, name, contact_info) VALUES
  (500000, 'Omni Music Publishing', 'http://www.omnimusicpublishing.com/');

-- work_publisher
INSERT INTO work_publisher (publisher_id, work_id) VALUES
  (500000, 01012016),
  (500000, 01022016),
  (500000, 01032016),
  (500000, 01042016),
  (500000, 01052016),
  (500000, 01062016);

-- extreme sample data to test edge cases
INSERT INTO works (id, title, secondary_title, year, country_id, media_type_id, finding_aid_link, digital_copy_link, material_format_id, cataloger_id, citation_source)
VALUES
  (1, 'Really, Really, Ridiculously Long Work Title is Here',
      'Really, Really, Ridiculously Long Subtitle is Here', 2017, 3, 9,
      'http://www.link-to-finding-aid.com/',
      'http://www.link-to-digital-copy.com/', 8, 2, 'Testing 1, 2, 3...');

INSERT INTO work_collection (work_id, collection_id) VALUES
  (1, 1);

INSERT INTO work_composer (composer_id, work_id) VALUES
  (200000, 1),
  (200001, 1),
  (200002, 1),
  (200003, 1),
  (200004, 1),
  (200005, 1),
  (200006, 1),
  (200007, 1);

INSERT INTO work_director (director_id, work_id) VALUES
  (300000, 1),
  (300001, 1),
  (300002, 1),
  (300003, 1),
  (300004, 1),
  (300005, 1),
  (300006, 1),
  (300007, 1),
  (300008, 1);

INSERT INTO work_production_company (production_company_id, work_id) VALUES
  (400000, 1),
  (400001, 1),
  (400002, 1),
  (400003, 1),
  (400004, 1),
  (400005, 1);

INSERT INTO work_publisher (publisher_id, work_id) VALUES
  (500000, 1);
