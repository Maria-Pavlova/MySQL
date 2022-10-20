ALTER TABLE `products` 
ADD INDEX `fk_categories_index` (`category_id` ASC) invisible;
;
ALTER TABLE `products` 
ADD CONSTRAINT `fk_category_id`
  FOREIGN KEY (`category_id`)
  REFERENCES `categories` (`id`)
  ON DELETE RESTRICT
  ON UPDATE CASCADE;
  
  ALTER TABLE `employees`
  ADD COLUMN `salary` DECIMAL(10, 2) NOT NULL DEFAULT 0;
  
  ALTER TABLE `employees`
  ADD COLUMN `middle_name` VARCHAR(50) NOT NULL DEFAULT '';
  
  ALTER TABLE `employees`
  MODIFY `middle_name` VARCHAR(100) NOT NULL DEFAULT '';