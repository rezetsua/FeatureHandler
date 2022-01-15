#include "core_module.h"

CoreModule::CoreModule(QString appPath, QObject *parent) : QObject(parent)
{
    detectorSourcePath = "";
    detectorOutputPath = appPath.toStdString() + "/detOut.jpg";
    descriptorSourcePath1 = "";
    descriptorSourcePath2 = "";
    descriptorOutputPath = appPath.toStdString() + "/desOut.jpg";
    flowSourcePath = "";
}

void CoreModule::keyPointDetector(int detector_enum, Mat &input_img, Mat &output_img)
{
    Ptr<cv::Feature2D> detector;
    QString detector_name;

    switch (detector_enum) {
    case GFTT_Detector: {
        // Увеличить количество точек: maxCorners+
        detector = GFTTDetector::create(3000, 0.01, 1, 3, false, 0.04);
        detector_name = "GFTT Detector";
        break;
    }
    case FAST_Detector: {
        // Увеличить количество точек: threshold-, type = TYPE_9_16
        detector = FastFeatureDetector::create(20, true, FastFeatureDetector::TYPE_9_16);
        detector_name = "FAST Detector";
        break;
    }
    case AGAST_Detector: {
        // Увеличить количество точек: threshold-, type = OAST_9_16
        detector = AgastFeatureDetector::create(14, true, AgastFeatureDetector::AGAST_5_8);
        detector_name = "AGAST Detector";
        break;
    }
    case SimpleBlob_Detector: {
        // Увеличить количество точек: minArea-
        // Setup SimpleBlobDetector parameters.
        SimpleBlobDetector::Params params;
        // Change thresholds
        params.minThreshold = 10;
        params.maxThreshold = 200;
        // Filter by Area.
        params.filterByArea = true;
        params.minArea = 5;
        // Filter by Circularity
        params.filterByCircularity = false;
        params.minCircularity = 0.1;
        // Filter by Convexity
        params.filterByConvexity = false;
        params.minConvexity = 0.87;
        // Filter by Inertia
        params.filterByInertia = false;
        params.minInertiaRatio = 0.01;
        detector = SimpleBlobDetector::create(params);
        detector_name = "SimpleBlob Detector";
        break;
    }
    case SIFT_Detector: {
        detector = SIFT::create(0, 3, 0.04, 10, 1.6);
        detector_name = "SIFT Detector";
        break;
    }
    case MSER_Detector: {
        // Увеличить количество точек: delta-, max_variation+
        detector = MSER::create(5, 60, 14400, 0.25, 0.2, 200, 1.01, 0.003, 5);
        detector_name = "MSER Detector";
        break;
    }
    case KAZE_Detector: {
        // Увеличить количество точек: threshold-, diffusivity = DIFF_CHARBONNIER
        detector = KAZE::create(false, false, 0.0005f, 4, 4, KAZE::DIFF_PM_G2);
        detector_name = "KAZE Detector";
        break;
    }
    case AKAZE_Detector: {
        // Увеличить количество точек: threshold-, diffusivity = DIFF_CHARBONNIER
        detector = AKAZE::create(AKAZE::DESCRIPTOR_MLDB, 0, 3, 0.0005f, 4, 4, KAZE::DIFF_PM_G2);
        detector_name = "AKAZE Detector";
        break;
    }
    }

    vector<KeyPoint> key_points;
    double t = (double)getTickCount();
    detector->detect(input_img, key_points);
    t = ((double)getTickCount() - t)/getTickFrequency();
    drawKeypoints(input_img, key_points, output_img);

    qDebug() << "\n" << detector_name
             << "\n" << "      time costs:         " << t
             << "\n" << "      keypoints detected: " << key_points.size() << "\n";

    detectorTimeCost_ = t;
    detectorKeyPointAmount_ = key_points.size();
    emit detectorTimeCostChanged();
    emit detectorKeyPointAmountChanged();
}

void CoreModule::keyPointDescriptor(int descriptor_enum, Mat &input1_img, Mat &input2_img, Mat &output_img)
{
    Ptr<cv::Feature2D> detector;
    QString descriptor_name;

    switch (descriptor_enum) {
    case SIFT_Descriptor: {
        detector = SIFT::create(0, 3, 0.04, 10, 1.6);
        descriptor_name = "SIFT Descriptor";
        break;
    }
    case ORB_Descriptor: {
        // Увеличить количество точек: nfeatures+
        detector = ORB::create(5000, 1.2f, 8, 31, 0, 2, ORB::FAST_SCORE, 31, 20);
        descriptor_name = "ORB Descriptor";
        break;
    }
//    case MSER_Descriptor: {
//        // Увеличить количество точек: delta-, max_variation+
//        detector = MSER::create(5, 60, 14400, 0.25, 0.2, 200, 1.01, 0.003, 5);
//        descriptor_name = "MSER Detector";
//        break;
//    }
    case KAZE_Descriptor: {
        // Увеличить количество точек: threshold-, diffusivity = DIFF_CHARBONNIER
        detector = KAZE::create(false, false, 0.0005f, 4, 4, KAZE::DIFF_PM_G2);
        descriptor_name = "KAZE Descriptor";
        break;
    }
    case AKAZE_Descriptor: {
        // Увеличить количество точек: threshold-, diffusivity = DIFF_CHARBONNIER
        detector = AKAZE::create(AKAZE::DESCRIPTOR_MLDB, 0, 3, 0.0005f, 4, 4, KAZE::DIFF_PM_G2);
        descriptor_name = "AKAZE Descriptor";
        break;
    }
    case BRISK_Descriptor: {
        // Увеличить количество точек: thresh-
        detector = BRISK::create(30, 3, 1.0f);
        descriptor_name = "BRISK Descriptor";
        break;
    }
    }

    //-- Step 1: Detect the keypoints using SURF Detector, compute the descriptors
    std::vector<KeyPoint> keypoints1, keypoints2;
    Mat descriptors1, descriptors2;
    double t = (double)getTickCount();
    detector->detectAndCompute( input1_img, noArray(), keypoints1, descriptors1 );
    detector->detectAndCompute( input2_img, noArray(), keypoints2, descriptors2 );
    t = ((double)getTickCount() - t)/getTickFrequency();

    //-- Step 2: Matching descriptor vectors with a FLANN based matcher
    Ptr<DescriptorMatcher> matcher = DescriptorMatcher::create(DescriptorMatcher::BRUTEFORCE);
    std::vector< std::vector<DMatch> > knn_matches;
    matcher->knnMatch( descriptors1, descriptors2, knn_matches, 2 );

    //-- Filter matches using the Lowe's ratio test
    const float ratio_thresh = 0.7f;
    std::vector<DMatch> good_matches;
    for (size_t i = 0; i < knn_matches.size(); i++)
    {
        if (knn_matches[i][0].distance < ratio_thresh * knn_matches[i][1].distance)
        {
            good_matches.push_back(knn_matches[i][0]);
        }
    }
    //-- Draw matches
    drawMatches( input1_img, keypoints1, input2_img, keypoints2, good_matches, output_img, Scalar::all(-1),
                 Scalar::all(-1), std::vector<char>(), DrawMatchesFlags::NOT_DRAW_SINGLE_POINTS );

    qDebug() << "\n" << descriptor_name
             << "\n" << "      time costs:         " << t
             << "\n" << "      keypoints matched: " << good_matches.size() << "\n";

    descriptorTimeCost_ = t;
    descriptorKeyPointAmount_ = good_matches.size();
    emit descriptorTimeCostChanged();
    emit descriptorKeyPointAmountChanged();
}

int CoreModule::opticalFlow(const string filename, int flow_enum, bool to_gray = false, bool save = false)
{
    if (flow_enum == LUCAS_KANADA_SPARSE) {
        VideoCapture capture(filename);
        if (!capture.isOpened()){
            //error in opening the video input
            cerr << "Unable to open file!" << endl;
            return 1;
        }
        // Create some random colors
        vector<Scalar> colors;
        RNG rng;
        for(int i = 0; i < 2000; i++)
        {
            int r = rng.uniform(0, 256);
            int g = rng.uniform(0, 256);
            int b = rng.uniform(0, 256);
            colors.push_back(Scalar(r,g,b));
        }
        Mat old_frame, old_gray;
        vector<Point2f> p0, p1;
        // Take first frame and find corners in it
        capture >> old_frame;
        cvtColor(old_frame, old_gray, COLOR_BGR2GRAY);
        goodFeaturesToTrack(old_gray, p0, 2000, 0.1, 7, Mat(), 7, false, 0.04);
        // Create a mask image for drawing purposes
        Mat mask = Mat::zeros(old_frame.size(), old_frame.type());
        while(playFlag){
            double t = (double)getTickCount();
            Mat frame, frame_gray;
            capture >> frame;
            if (frame.empty()) {
                break;
            }

            //imshow("Frame", frame);
            QImage in_img = QImage(frame.data,frame.cols,frame.rows,QImage::Format_RGB888).rgbSwapped();
            emit newImageIn(in_img);

            cvtColor(frame, frame_gray, COLOR_BGR2GRAY);
            // calculate optical flow
            vector<uchar> status;
            vector<float> err;
            TermCriteria criteria = TermCriteria((TermCriteria::COUNT) + (TermCriteria::EPS), 10, 0.03);
            calcOpticalFlowPyrLK(old_gray, frame_gray, p0, p1, status, err, Size(15,15), 2, criteria);
            vector<Point2f> good_new;
            for(uint i = 0; i < p0.size(); i++)
            {
                // Select good points
                if(status[i] == 1) {
                    good_new.push_back(p1[i]);
                    // draw the tracks
                    line(mask,p1[i], p0[i], colors[i], 2);
                    circle(frame, p1[i], 5, colors[i], -1);
                }
            }
            Mat img;
            add(frame, mask, img);

            //imshow("Flow", img);
            QImage out_img = QImage(img.data,img.cols,img.rows,QImage::Format_RGB888).rgbSwapped();
            emit newImageOut(out_img);

            int keyboard = waitKey(1);
            if (keyboard == 'q' || keyboard == 27)
                return 0;
            // Now update the previous frame and previous points
            old_gray = frame_gray.clone();
            p0 = good_new;
            t = ((double)getTickCount() - t)/getTickFrequency();
            flowFPS = 1/t;
//            qDebug() << "t" << t;
//            qDebug() << "FPS" << flowFPS;
            emit flowFPSChanged();
        }
    }
    else if (flow_enum == LUCAS_KANADA_DENSE) {
        VideoCapture capture(samples::findFile(filename));
        if (!capture.isOpened()) {
            //error in opening the video input
            cerr << "Unable to open file!" << endl;
        }
        Mat frame1, prvs;
        capture >> frame1;
        if (to_gray)
            cvtColor(frame1, prvs, COLOR_BGR2GRAY);
        else
            prvs = frame1;
        int counter = 0;
        while(playFlag) {
            double t = (double)getTickCount();
            Mat frame2, next;
            capture >> frame2;
            if (frame2.empty())
                break;
            if (to_gray)
                cvtColor(frame2, next, COLOR_BGR2GRAY);
            else
                next = frame2;
            Mat flow(prvs.size(), CV_32FC2);
            cv::optflow::calcOpticalFlowSparseToDense(prvs, next, flow, 8, 128, 0.05f, true, 500.0f, 1.5f);
            // visualization
            Mat flow_parts[2];
            split(flow, flow_parts);
            Mat magnitude, angle, magn_norm;
            cartToPolar(flow_parts[0], flow_parts[1], magnitude, angle, true);
            normalize(magnitude, magn_norm, 0.0f, 1.0f, NORM_MINMAX);
            angle *= ((1.f / 360.f) * (180.f / 255.f));
            //build hsv image
            Mat _hsv[3], hsv, hsv8, bgr;
            _hsv[0] = angle;
            _hsv[1] = Mat::ones(angle.size(), CV_32F);
            _hsv[2] = magn_norm;
            merge(_hsv, 3, hsv);
            hsv.convertTo(hsv8, CV_8U, 255.0);
            cvtColor(hsv8, bgr, COLOR_HSV2BGR);
            if (save) {
                string save_path = "./optical_flow_frames/frame_" + to_string(counter) + ".jpg";
                imwrite(save_path, bgr);
            }

            //imshow("frame", frame2);
            //imshow("flow", bgr);
            QImage in_img = QImage(frame2.data,frame2.cols,frame2.rows,QImage::Format_RGB888).rgbSwapped();
            emit newImageIn(in_img);
            QImage out_img = QImage(bgr.data,bgr.cols,bgr.rows,QImage::Format_RGB888).rgbSwapped();
            emit newImageOut(out_img);

            int keyboard = waitKey(1);
            if (keyboard == 'q' || keyboard == 27)
                break;
            prvs = next;
            counter++;
            t = ((double)getTickCount() - t)/getTickFrequency();
            flowFPS = 1/t;
//            qDebug() << "t" << t;
//            qDebug() << "FPS" << flowFPS;
            emit flowFPSChanged();
        }
    }
    else if (flow_enum == FARNEBACK) {
        VideoCapture capture(samples::findFile(filename));
        if (!capture.isOpened()){
            //error in opening the video input
            cerr << "Unable to open file!" << endl;
            return 1;
        }
        Mat frame1, prvs;
        capture >> frame1;
        cvtColor(frame1, prvs, COLOR_BGR2GRAY);
        while(playFlag){
            double t = (double)getTickCount();
            Mat frame2, next;
            capture >> frame2;
            if (frame2.empty())
                break;

            QImage in_img = QImage(frame2.data,frame2.cols,frame2.rows,QImage::Format_RGB888).rgbSwapped();
            emit newImageIn(in_img);

            cvtColor(frame2, next, COLOR_BGR2GRAY);
            Mat flow(prvs.size(), CV_32FC2);
            calcOpticalFlowFarneback(prvs, next, flow, 0.5, 3, 15, 3, 5, 1.2, 0);
            // visualization
            Mat flow_parts[2];
            split(flow, flow_parts);
            Mat magnitude, angle, magn_norm;
            cartToPolar(flow_parts[0], flow_parts[1], magnitude, angle, true);
            normalize(magnitude, magn_norm, 0.0f, 1.0f, NORM_MINMAX);
            angle *= ((1.f / 360.f) * (180.f / 255.f));
            //build hsv image
            Mat _hsv[3], hsv, hsv8, bgr;
            _hsv[0] = angle;
            _hsv[1] = Mat::ones(angle.size(), CV_32F);
            _hsv[2] = magn_norm;
            merge(_hsv, 3, hsv);
            hsv.convertTo(hsv8, CV_8U, 255.0);
            cvtColor(hsv8, bgr, COLOR_HSV2BGR);

            //imshow("frame2", bgr);
            QImage out_img = QImage(bgr.data,bgr.cols,bgr.rows,QImage::Format_RGB888).rgbSwapped();
            emit newImageOut(out_img);

            int keyboard = waitKey(1);
            if (keyboard == 'q' || keyboard == 27)
                return 0;
            prvs = next;
            t = ((double)getTickCount() - t)/getTickFrequency();
            flowFPS = 1/t;
//            qDebug() << "t" << t;
//            qDebug() << "FPS" << flowFPS;
            emit flowFPSChanged();
        }
    }
    else if (flow_enum == RLOF){
        to_gray = false;
        VideoCapture capture(samples::findFile(filename));
        if (!capture.isOpened()) {
            //error in opening the video input
            cerr << "Unable to open file!" << endl;
        }
        Mat frame1, prvs;
        capture >> frame1;
        if (to_gray)
            cvtColor(frame1, prvs, COLOR_BGR2GRAY);
        else
            prvs = frame1;
        int counter = 0;
        while(playFlag) {
            double t = (double)getTickCount();
            Mat frame2, next;
            capture >> frame2;
            if (frame2.empty())
                break;
            if (to_gray)
                cvtColor(frame2, next, COLOR_BGR2GRAY);
            else
                next = frame2;
            Mat flow(prvs.size(), CV_32FC2);
            cv::optflow::calcOpticalFlowDenseRLOF(prvs, next, flow,
                                                  Ptr<cv::optflow::RLOFOpticalFlowParameter>(), 1.f, Size(6,6),
                                                  cv::optflow::InterpolationType::INTERP_EPIC,
                                                  128, 0.05f, 999.0f, 15, 100, true, 500.0f, 1.5f, false);
            // visualization
            Mat flow_parts[2];
            split(flow, flow_parts);
            Mat magnitude, angle, magn_norm;
            cartToPolar(flow_parts[0], flow_parts[1], magnitude, angle, true);
            normalize(magnitude, magn_norm, 0.0f, 1.0f, NORM_MINMAX);
            angle *= ((1.f / 360.f) * (180.f / 255.f));
            //build hsv image
            Mat _hsv[3], hsv, hsv8, bgr;
            _hsv[0] = angle;
            _hsv[1] = Mat::ones(angle.size(), CV_32F);
            _hsv[2] = magn_norm;
            merge(_hsv, 3, hsv);
            hsv.convertTo(hsv8, CV_8U, 255.0);
            cvtColor(hsv8, bgr, COLOR_HSV2BGR);
            if (save) {
                string save_path = "./optical_flow_frames/frame_" + to_string(counter) + ".jpg";
                imwrite(save_path, bgr);
            }

//            imshow("frame", frame2);
//            imshow("flow", bgr);
            QImage in_img = QImage(frame2.data,frame2.cols,frame2.rows,QImage::Format_RGB888).rgbSwapped();
            emit newImageIn(in_img);
            QImage out_img = QImage(bgr.data,bgr.cols,bgr.rows,QImage::Format_RGB888).rgbSwapped();
            emit newImageOut(out_img);

            int keyboard = waitKey(1);
            if (keyboard == 'q' || keyboard == 27)
                return 0;
            prvs = next;
            counter++;
            t = ((double)getTickCount() - t)/getTickFrequency();
            flowFPS = 1/t;
//            qDebug() << "t" << t;
//            qDebug() << "FPS" << flowFPS;
            emit flowFPSChanged();
        }
    }
    return 0;
}

QString CoreModule::getDetectorSourcePath()
{
    QString answer = QString::fromStdString(detectorSourcePath);
    return answer;
}

QString CoreModule::getDetectorOutputPath()
{
    QString answer = QString::fromStdString(detectorOutputPath);
    return answer;
}

QString CoreModule::getDescriptorSourcePath1()
{
    QString answer = QString::fromStdString(descriptorSourcePath1);
    return answer;
}

QString CoreModule::getDescriptorSourcePath2()
{
    QString answer = QString::fromStdString(descriptorSourcePath2);
    return answer;
}

QString CoreModule::getDescriptorOutputPath()
{
    QString answer = QString::fromStdString(descriptorOutputPath);
    return answer;
}

QString CoreModule::getFlowSourcePath()
{
    QString answer = QString::fromStdString(flowSourcePath);
    return answer;
}

void CoreModule::setDetectorSourcePath(QString filename)
{
    detectorSourcePath = filename.toStdString();
    detectorSourcePath.erase(0,7);
    emit detectorSourcePathChanged();
}

void CoreModule::setDescriptorSourcePath1(QString filename)
{
    descriptorSourcePath1 = filename.toStdString();
    descriptorSourcePath1.erase(0,7);
    emit descriptorSourcePath1Changed();
}

void CoreModule::setDescriptorSourcePath2(QString filename)
{
    descriptorSourcePath2 = filename.toStdString();
    descriptorSourcePath2.erase(0,7);
    emit descriptorSourcePath2Changed();
}

void CoreModule::setFlowSourcePath(QString filename)
{
    flowSourcePath = filename.toStdString();
    flowSourcePath.erase(0,7);
    emit flowSourcePathChanged();
}

void CoreModule::detectKeyPoint(const int detectorIndex)
{
    Mat source1_img = imread(detectorSourcePath, IMREAD_GRAYSCALE);
    Mat output_img = source1_img.clone();
    keyPointDetector(detectorIndex, source1_img, output_img);
    imwrite(detectorOutputPath, output_img);
    emit detectedOutputReady();
}

void CoreModule::descriptKeyPoint(int descriptorIndex)
{
    Mat source1_img = imread(descriptorSourcePath1, IMREAD_GRAYSCALE);
    Mat source2_img = imread(descriptorSourcePath2, IMREAD_GRAYSCALE);
    Mat output_img = source1_img.clone();
    keyPointDescriptor(descriptorIndex, source1_img, source2_img, output_img);
    imwrite(descriptorOutputPath, output_img);
    emit descriptorOutputReady();
}

void CoreModule::createOpticalFlow(int flowIndex)
{
    opticalFlow(flowSourcePath, flowIndex);
}
