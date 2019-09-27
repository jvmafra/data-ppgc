library(tidyverse)


authors <- read.csv(file = "/local/mafra/visualizacao-ppgc/data/authors.csv", header = FALSE, sep = ",")
colnames(authors) = c("paper_id", "pos", "author")


papers <- read.csv(file = "/local/mafra/visualizacao-ppgc/data/papers.csv", header = FALSE, sep = ",")
colnames(papers) = c("global_id", "paper_id", "conf_id", "link", "title", "pages", "citations")

conferences <- read.csv(file = "/local/mafra/visualizacao-ppgc/data/conferences.csv", header = FALSE, sep = ",")
colnames(conferences) = c("global_id", "conf_id", "year", "publisher", "title", "link",
                          "computer_science", "data_engineering", "software_engineering", "theory")


ethnicity <- read.csv(file = "/local/mafra/visualizacao-ppgc/data/ethnicity.csv", header = FALSE, sep = ",")
colnames(ethnicity) = c("author", "l0", "l1", "l2", "gender")


join.authors.papers <- merge(authors, papers, by = "paper_id")
join.conferences <- merge(join.authors.papers, conferences, by = "conf_id")
join.eth <- merge(join.conferences, ethnicity, by = "author")

final.df <- join.eth %>% select(paper_id,author, pos, year, computer_science, data_engineering, software_engineering, theory, ethn = l1, gender) %>%
  filter(gender %in% c("M", "F"))
final.df.first.auhtor <- final.df %>% filter(pos == 0, gender %in% c("M", "F"))


write.table(final.df, "/local/mafra/visualizacao-ppgc/data/papers_all_authors.csv", sep = ",", row.names = FALSE, col.names = TRUE, quote = FALSE)
write.table(final.df.first.auhtor, "/local/mafra/visualizacao-ppgc/data/papers_first_author.csv", sep = ",", row.names = FALSE, col.names = TRUE, quote = FALSE)


defined.area.cs <- final.df.first.auhtor %>%
  filter(computer_science == 1 & data_engineering == 0 & software_engineering == 0 & theory == 0) %>%
  dplyr::mutate(area = "computer_science")


defined.area.de <- final.df.first.auhtor %>%
  filter(computer_science == 0 & data_engineering == 1 & software_engineering == 0 & theory == 0)  %>% 
  dplyr::mutate(area = "data_engineering")

defined.area.se <- final.df.first.auhtor %>%
  filter(computer_science == 0 & data_engineering == 0 & software_engineering == 1 & theory == 0) %>% 
  dplyr::mutate(area = "software_engineering")

defined.area.theory <- final.df.first.auhtor %>%
  filter(computer_science == 0 & data_engineering == 0 & software_engineering == 0 & theory == 1) %>%
  dplyr::mutate(area = "theory")

a <- rbind(defined.area.cs, defined.area.de)

binded.papers <- do.call(rbind, list(defined.area.cs,
                                     defined.area.de,
                                     defined.area.se,
                                     defined.area.theory
))

write.table(binded.papers, "/local/mafra/visualizacao-ppgc/data/papers_defined_area.csv", sep = ",", row.names = FALSE, col.names = TRUE, quote = FALSE)

