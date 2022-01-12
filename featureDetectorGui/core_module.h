#ifndef COREMODULE_H
#define COREMODULE_H

#include <QObject>
#include <QDebug>
#include <QImage>
#include <QFileDialog>

#include <opencv2/opencv.hpp>
#include <opencv2/features2d.hpp>
#include <opencv2/highgui.hpp>
#include <opencv2/imgproc.hpp>
#include <opencv2/videoio.hpp>
#include <opencv2/video.hpp>
#include <opencv2/optflow.hpp>

using namespace cv;
using namespace std;

enum Detectors {
    GFTT_Detector = 0,
    FAST_Detector,
    AGAST_Detector,
    SimpleBlob_Detector,
    SIFT_Detector,
    MSER_Detector,
    KAZE_Detector,
    AKAZE_Detector
};

enum Descriptors {
    SIFT_Descriptor = 0,
    ORB_Descriptor,
    //MSER_Descriptor,
    KAZE_Descriptor,
    AKAZE_Descriptor,
    BRISK_Descriptor
};

enum Flow {
    LUCAS_KANADA_SPARSE = 0,
    LUCAS_KANADA_DENSE,
    FARNEBACK,
    RLOF
};

class CoreModule : public QObject
{
    Q_OBJECT

    Q_PROPERTY(double detectorTimeCost MEMBER detectorTimeCost_ NOTIFY detectorTimeCostChanged)
    Q_PROPERTY(int detectorKeyPointAmount MEMBER detectorKeyPointAmount_ NOTIFY detectorKeyPointAmountChanged)

    Q_PROPERTY(double descriptorTimeCost MEMBER descriptorTimeCost_ NOTIFY descriptorTimeCostChanged)
    Q_PROPERTY(int descriptorKeyPointAmount MEMBER descriptorKeyPointAmount_ NOTIFY descriptorKeyPointAmountChanged)

    Q_PROPERTY(int flowFPS MEMBER flowFPS NOTIFY flowFPSChanged)
    Q_PROPERTY(bool playFlag MEMBER playFlag NOTIFY playFlagChanged)
    Q_PROPERTY(QString flowSourcePath READ getFlowSourcePath NOTIFY flowSourcePathChanged)

    Q_PROPERTY(QString detectorSourcePath READ getDetectorSourcePath NOTIFY detectorSourcePathChanged)
    Q_PROPERTY(QString detectorOutputPath READ getDetectorOutputPath NOTIFY detectorOutputPathChanged)

    Q_PROPERTY(QString descriptorSourcePath1 READ getDescriptorSourcePath1 NOTIFY descriptorSourcePath1Changed)
    Q_PROPERTY(QString descriptorSourcePath2 READ getDescriptorSourcePath2 NOTIFY descriptorSourcePath2Changed)
    Q_PROPERTY(QString descriptorOutputPath READ getDescriptorOutputPath NOTIFY descriptorOutputPathChanged)

public:
    explicit CoreModule(QString appPath, QObject *parent = nullptr);

    void keyPointDetector(int detector_enum, Mat &input_img, Mat &output_img);
    void keyPointDescriptor(int descriptor_enum, Mat &input1_img, Mat &input2_img, Mat &output_img);

    int opticalFlow(const string filename, int flow_enum, bool to_gray, bool save);

    QString getDetectorSourcePath();
    QString getDetectorOutputPath();

    QString getDescriptorSourcePath1();
    QString getDescriptorSourcePath2();
    QString getDescriptorOutputPath();
    QString getFlowSourcePath();

public slots:
    void setDetectorSourcePath(QString filename);
    void setDescriptorSourcePath1(QString filename);
    void setDescriptorSourcePath2(QString filename);
    void setFlowSourcePath(QString filename);

    void detectKeyPoint(int detectorIndex);
    void descriptKeyPoint(int descriptorIndex);
    void createOpticalFlow(int flowIndex);

signals:
    void detectorTimeCostChanged();
    void detectorKeyPointAmountChanged();

    void descriptorTimeCostChanged();
    void descriptorKeyPointAmountChanged();

    void detectorSourcePathChanged();
    void detectorOutputPathChanged();

    void descriptorSourcePath1Changed();
    void descriptorSourcePath2Changed();
    void descriptorOutputPathChanged();

    void detectedOutputReady();
    void descriptorOutputReady();

    void flowFPSChanged();
    void playFlagChanged();
    void flowSourcePathChanged();
    void newImageIn(QImage &);
    void newImageOut(QImage &);

public:
    double detectorTimeCost_ = 0;
    int detectorKeyPointAmount_ = 0;

    double descriptorTimeCost_ = 0;
    int descriptorKeyPointAmount_ = 0;

    int flowFPS = 0;
    bool playFlag = true;

    string detectorSourcePath;
    string detectorOutputPath;

    string descriptorSourcePath1;
    string descriptorSourcePath2;
    string descriptorOutputPath;

    string flowSourcePath;
};

#endif // COREMODULE_H
