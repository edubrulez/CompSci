;;; Erick Nave
;;; Survey of Programming Languages
;;; Program Assignment 4
;;; Start 4-15-94
;;; Last Update 4-19-94

(defun count-atoms (x)
;;; count- atoms counts the number of non nil atoms in x
   (cond
      ((null x) 0)
      ((atom x) 1)
      (t (+ (count-atoms (car x)) (count-atoms (cdr x))))))

(defun remove-dup (x y)
;;; remove-dup removes the atom in y that matches x
   (cond
      ((equalp x (car y)) (cdr y))
      (t (cons (car y) (remove-dup x (cdr y))))))

(defun symmdiff (x y)
;;; symmdiff takes the symmetric difference of x and y
   (cond
      ((null x) y)
      ((null y) x)
      ((member (car x) y) (symmdiff (cdr x) (remove-dup (car x) y)))
      (t (cons (car x) (symmdiff (cdr x) y)))))

(defun mirror (x)
;;; mirror reverses all items at all levels of x
   (cond
      ((atom x) x)
      ((atom (car x)) (append (mirror (cdr x)) (list (car x))))
      ((listp (car x)) (append (mirror (cdr x))
                               (list (mirror (car x)))))))

(defun infix-eval (x)
;;; infix-eval takes an infix expression x converts it to prefix and 
;;;     evaluates it
   (cond
      ((atom x) x)
      (t (eval (list (cadr x) (infix-eval (car x)) (infix-eval (caddr x)))))))

(defun countdups (x)
;;; countdups counts the number of instances the car of x is in x
   (cond
      ((null x) 0)
      ((null (member (car x) (cdr x))) 1)
      (t (+ 1 (countdups (member (car x) (cdr x)))))))

(defun remove-all-dups (x y)
;;; remove-all-dups removes all occurences of x in y
   (cond
      ((null y) nil)
      ((equalp x (car y)) (remove-all-dups x (cdr y)))
      (t (cons (car y) (remove-all-dups x (cdr y))))))

(defun tally (x)
;;; tally with the help of countdups counts the number of times a certain
;;;    atom is found in x and returns a list containing lists of atom
;;;    occurrence pairs.  remove-all-dups is called to remove the atom
;;;    from consideration to eliminate double counting.
   (cond 
      ((null x) nil)
      ((member (car x) (cdr x))
          (cons (list (car x) (countdups x))
                (tally (remove-all-dups (car x) x))))
      (t (cons (list (car x) 1) (tally (cdr x))))))
