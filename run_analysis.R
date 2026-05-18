# 进入数据集文件夹
setwd("UCI HAR Dataset")

# 读取所有原始数据
features <- read.table("features.txt", col.names = c("n","functions"))
activities <- read.table("activity_labels.txt", col.names = c("code","activity"))
x_train <- read.table("train/X_train.txt", col.names = features$functions)
y_train <- read.table("train/y_train.txt", col.names = "code")
subject_train <- read.table("train/subject_train.txt", col.names = "subject")
x_test <- read.table("test/X_test.txt", col.names = features$functions)
y_test <- read.table("test/y_test.txt", col.names = "code")
subject_test <- read.table("test/subject_test.txt", col.names = "subject")

# 步骤1：合并训练集+测试集
merged_data <- cbind(rbind(subject_train,subject_test), rbind(y_train,y_test), rbind(x_train,x_test))

# 步骤2：提取均值、标准差列
tidy_data <- merged_data[, grep("subject|code|mean\\(\\)|std\\(\\)", colnames(merged_data))]

# 步骤3：替换活动数字为文字（1→WALKING）
tidy_data <- merge(tidy_data, activities, by="code")
tidy_data <- tidy_data %>% select(-code) %>% relocate(activity, .after=subject)

# 步骤4：重命名变量（让列名易懂）
names(tidy_data) <- gsub("^t","time",names(tidy_data))
names(tidy_data) <- gsub("^f","frequency",names(tidy_data))
names(tidy_data) <- gsub("Acc","Accelerometer",names(tidy_data))
names(tidy_data) <- gsub("Gyro","Gyroscope",names(tidy_data))
names(tidy_data) <- gsub("Mag","Magnitude",names(tidy_data))
names(tidy_data) <- gsub("BodyBody","Body",names(tidy_data))
names(tidy_data) <- gsub("-mean\\(\\)","Mean",names(tidy_data))
names(tidy_data) <- gsub("-std\\(\\)","Std",names(tidy_data))
names(tidy_data) <- gsub("-","",names(tidy_data))

# 步骤5：按受试者+活动计算平均值
final_data <- tidy_data %>% group_by(subject,activity) %>% summarise_all(mean)

# 导出最终文件（必须加row.name=FALSE）
write.table(final_data, "tidy_data.txt", row.names=FALSE)

# 返回根目录
setwd("..")