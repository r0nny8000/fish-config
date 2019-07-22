function jenkins-shared-library
    echo ""
    java -jar $JENKINS_SHARED_LIBRARY_DIR/target/jenkins-shared-library-1.0.0-SNAPSHOT.jar $argv
end
