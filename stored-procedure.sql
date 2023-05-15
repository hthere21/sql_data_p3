CREATE TABLE IF NOT EXISTS employees (
  email VARCHAR(50) PRIMARY KEY,
  password VARCHAR(20) NOT NULL,
  fullname VARCHAR(100)
);

INSERT INTO employees (email, password, fullname)
VALUES ('classta@email.edu', 'classta', 'TA CS122B');

DROP PROCEDURE IF EXISTS add_movie;

DELIMITER $$

CREATE PROCEDURE add_movie (
        IN movie_title VARCHAR(100),
        IN movie_year INTEGER,
        IN movie_director VARCHAR(100),
        IN star_name VARCHAR(100),
        IN star_year INTEGER,
        IN genre_name VARCHAR(32)
)
BEGIN
    DECLARE genre_id INT;
    DECLARE star_id VARCHAR(10);
    DECLARE genre_message VARCHAR(100);
    DECLARE movie_message VARCHAR(100);

    -- check if movie already exists
    SELECT COUNT(*) INTO movie_message FROM movies WHERE title = movie_title AND year = movie_year AND director = movie_director;

    IF movie_message > 0 THEN
        SELECT "Error: Duplicated movie!" AS message;
    ELSE
        -- generate new movie ID
        SET @movieId = (SELECT MAX(CAST(SUBSTRING(id, 3) AS UNSIGNED)) + 1 FROM movies);
        SET @movieId = CONCAT('tt', @movieId);

        -- add new movie
        INSERT INTO movies (id, title, year, director) VALUES (@movieId, movie_title, movie_year, movie_director);

        -- check if genre already exists
        SELECT COUNT(*) INTO genre_id FROM genres WHERE name = genre_name;

        IF genre_id = 0 THEN
            -- generate new genre ID
            SET @genreId = (SELECT MAX(id) + 1 FROM genres);

            -- add new genre
            INSERT INTO genres (id, name) VALUES (@genreId, genre_name);
            SET genre_id = @genreId;
        ELSE
            -- get existing genre ID
            SELECT id INTO genre_id FROM genres WHERE name = genre_name LIMIT 1;
        END IF;

        -- add genre to movie
        INSERT INTO genres_in_movies (genreId, movieId) VALUES (genre_id, @movieId);

        -- check if star already exists
        SELECT COUNT(*) INTO star_id FROM stars WHERE name = star_name AND birthYear = star_year;

        IF star_id = 0 THEN
            -- generate new star ID
            SET @starId = (SELECT MAX(CAST(SUBSTRING(id, 3) AS UNSIGNED)) + 1 FROM stars);
            SET @starId = CONCAT('nm', @starId);

            -- add new star
            INSERT INTO stars (id, name, birthYear) VALUES (@starId, star_name, star_year);
            SET star_id = @starId;
        ELSE
            -- get existing star ID
            SELECT id INTO star_id FROM stars WHERE name = star_name AND birthYear = star_year LIMIT 1;
        END IF;

        -- add star to movie
        INSERT INTO stars_in_movies (starId, movieId) VALUES (star_id, @movieId);

        SELECT CONCAT("Success! MovieId: ", @movieId, ", StarId: ", star_id, ", GenreId: ", genre_id) AS message;
    END IF;
END$$

DELIMITER ;