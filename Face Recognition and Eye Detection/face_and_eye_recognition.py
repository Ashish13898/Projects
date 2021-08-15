import os
import cv2

VISION_TYPE = 1
PATH_TO_ADD_DETECTED_IMAGES = 'data/face_detection_labeled'

if not os.path.exists(VISION_TYPE):
    VISION_TYPE = os.environ["VISION_TYPE"]

def detect_from_image(face_cascade):
    imgList = [cv2.imread('data/images/other.jpeg'),cv2.imread('data/images/ashish.jpeg')]
    for index,img in enumerate(imgList):
        filePath = PATH_TO_ADD_DETECTED_IMAGES + '/woodcutters_detected_' + str(index) + '.jpg'
        gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
        faces = face_cascade.detectMultiScale(gray, 1.08, 5)
        for (x, y, w, h) in faces:
            roi_gray = gray[x:x + w, y:y + h]
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
            gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
            faces = face_cascade.detectMultiScale(
                gray, 1.3, 5, minSize=(120, 120))
            for (x, y, w, h) in faces:
                cv2.rectangle(frame, (x, y), (x+w, y+h), (255, 0, 0), 2)
                roi_gray = gray[y:y+h, x:x+w]
                eyes = eye_cascade.detectMultiScale(
                    roi_gray, 1.03, 5, minSize=(40, 40))
                for (ex, ey, ew, eh) in eyes:
                    cv2.rectangle(frame, (x+ex, y+ey),
                                  (x+ex+ew, y+ey+eh), (0, 255, 0), 2)
            cv2.imshow('Face Detection', frame)

if __name__ == "__main__":
    face_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_frontalface_default.xml')
    eye_cascade = cv2.CascadeClassifier(cv2.data.haarcascades + 'haarcascade_eye.xml')

    if VISION_TYPE:
        detect_from_image(face_cascade)
    else:
        live_detection(face_cascade)