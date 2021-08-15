import os
import cv2
import numpy

VISION_TYPE = 1
PATH_TO_TRAINING_IMAGES = './data/at'
PATH_TO_ADD_DETECTED_IMAGES = 'data/face_detection_labeled'
if not os.path.exists(VISION_TYPE):
    VISION_TYPE = os.environ["VISION_TYPE"]

def read_images(path, image_size):
    names = []
    training_images, training_labels = [], []
    label = 0
    for dirname, subdirnames, filenames in os.walk(path):
        for subdirname in subdirnames:
            names.append(subdirname)
            subject_path = os.path.join(dirname, subdirname)
            for filename in os.listdir(subject_path):
                img = cv2.imread(os.path.join(subject_path, filename),
                                 cv2.IMREAD_GRAYSCALE)
                if img is None:
                    # The file cannot be loaded as an image.
                    # Skip it.
                    continue
                img = cv2.resize(img, image_size)
                training_images.append(img)
                training_labels.append(label)
            label += 1
    training_images = numpy.asarray(training_images, numpy.uint8)
    training_labels = numpy.asarray(training_labels, numpy.int32)
    return names, training_images, training_labels

def detect_from_image(face_cascade):
    imgList = [cv2.imread('data/images/other.jpeg'),cv2.imread('data/images/ashish.jpeg')]
    for index,img in enumerate(imgList):
        filePath = PATH_TO_ADD_DETECTED_IMAGES + '/woodcutters_detected_' + str(index) + '.jpg'
        gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
        faces = face_cascade.detectMultiScale(gray, 1.08, 5)
        for (x, y, w, h) in faces:
            roi_gray = gray[x:x + w, y:y + h]
            label, confidence = model.predict(roi_gray)
            text = '%s, confidence=%.2f' % (names[label], confidence)
            cv2.putText(img, text, (x, y - 20), cv2.FONT_HERSHEY_SIMPLEX, 1, (255, 0, 0), 2)
            img = cv2.rectangle(img, (x, y), (x + w, y + h), (255, 0, 0), 2)

        cv2.namedWindow('Woodcutters Detected!')
        cv2.imshow('Woodcutters Detected!', img)
        cv2.imwrite(filePath, img)
        # press a key to see next image
        cv2.waitKey(0)

def live_detection(face_cascade):
    camera = cv2.VideoCapture(0)
    while (cv2.waitKey(1) == -1):
        success, frame = camera.read()
        if success:
            faces = face_cascade.detectMultiScale(frame, 1.3, 5)
            for (x, y, w, h) in faces:
                cv2.rectangle(frame, (x, y), (x+w, y+h), (255, 0, 0), 2)
                gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
                roi_gray = gray[x:x+w, y:y+h]
                if roi_gray.size == 0:
                    # The ROI is empty. Maybe the face is at the image edge.
                    # Skip it.
                    continue
                roi_gray = cv2.resize(roi_gray, training_image_size)
                label, confidence = model.predict(roi_gray)
                text = '%s, confidence=%.2f' % (names[label], confidence)
                cv2.putText(frame, text, (x, y - 20),
                            cv2.FONT_HERSHEY_SIMPLEX, 1, (255, 0, 0), 2)
            cv2.imshow('Face Recognition', frame)

if __name__ == "__main__":

    training_image_size = (200, 200)
    names, training_images, training_labels = read_images(PATH_TO_TRAINING_IMAGES, training_image_size)

    model = cv2.face.LBPHFaceRecognizer_create()
    model.train(training_images, training_labels)

    face_cascade = cv2.CascadeClassifier('./cascades/haarcascade_frontalface_default.xml')

    face_cascade = cv2.CascadeClassifier('./cascades/haarcascade_frontalface_default.xml')
    if VISION_TYPE:
        detect_from_image(face_cascade)
    else:
        live_detection(face_cascade)


