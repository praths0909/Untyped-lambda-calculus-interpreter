def letter?(lookAhead)
    lookAhead.match?(/[a-z]/)
end

def is_abstraction(term)
    if term[0]=="("
        return true
    else
        return false
    end
end

def is_application(term)
    if term[0]=="["
        return true
    else
        return false
    end
end


def beta_reduce_abstraction(term,new_variable)
    a=term[2]
    replace_free_variable_caller(a,term[4..-2],new_variable)
end

def is_valid_lambda_term_caller(term)
    n=term.length
    if n==0
        return true
    end
    if term[0]=="("

        if term[n-1]!=")" || term[1]!="\\" || letter?(term[2])==false||term[3]!="."
            return false
        else
            return is_valid_lambda_term_caller(term[4..-2])
        end
    elsif term[0]=="["
        lhs="["
        rhs=""
        left_count=1
        flag=0
        for i in (1...n)
            if flag==0
                lhs+=term[i]
            elsif flag==1
                rhs+=term[i]
            else
                return false
            end

            if term[i]=="["
                left_count+=1
            elsif term[i]=="]"
                left_count-=1
            end
            if left_count==0
                if flag==0
                    flag=1
                else
                    flag=2
                end
            end
        end
        if rhs.length==0
            return false
        end
        n1=lhs.length
        n2=rhs.length
        return is_valid_lambda_term_caller(rhs[1..n2-2]) && is_valid_lambda_term_caller(lhs[1..n1-2])
    elsif term.length==1 && letter?(term)==true
        return true
    else
        return false
    end
end

def is_valid_lambda_term(term)
    if is_valid_lambda_term_caller(term)==true
        puts "Yes this is a valid lambda term"
    else
        puts "Not a valid lambda term"
    end
end

def free_terms_caller(term)
    n=term.length
    a=Array.new
    if n==0
        return a
    end
    if term[0]=="("
        b=free_terms_caller(term[4..-2])
        b.delete(term[2])
        return b
    elsif term[0]=="["
        lhs="["
        rhs=""
        left_count=1
        flag=0
        for i in (1...n)
            if flag==0
                lhs+=term[i]
            elsif flag==1
                rhs+=term[i]
            else
                return
            end
            if term[i]=="["
                left_count+=1
            elsif term[i]=="]"
                left_count-=1
            end
            if left_count==0
                if flag==0
                    flag=1
                else
                    flag=2
                end
            end
        end
        n1=lhs.length
        n2=rhs.length
        b=free_terms_caller(rhs[1..n2-2])
        c=free_terms_caller(lhs[1..n1-2])
        b=b.union(c)
        return b
    elsif term.length==1 && letter?(term)==true
        a=Array.new
        a.append(term[0])
        return a
    else
        a=Array.new
        return a
    end
end

def free_terms(term)
    if is_valid_lambda_term_caller(term)==false
        puts "Not a valid term according to given syntax.Please go through README file to see correct syntax and type according to it\n"
    else
        a=free_terms_caller(term)
        puts "Free variables are"
        puts a
    end
end

def replace_free_variable_caller(free_variable,term,new_term)
    n=term.length
    if n==0
        return term
    end
    if term[0]=="("
        if term[2]==free_variable
            return term
        else
            return term[0..3]+replace_free_variable_caller(free_variable,term[4..-2],new_term)+")"
        end
    elsif term[0]=="["
        lhs="["
        rhs=""
        left_count=1
        flag=0
        for i in (1...n)
            if flag==0
                lhs+=term[i]
            elsif flag==1
                rhs+=term[i]
            else
                return ""
            end

            if term[i]=="["
                left_count+=1
            elsif term[i]=="]"
                left_count-=1
            end
            if left_count==0
                if flag==0
                    flag=1
                else
                    flag=2
                end
            end
        end
        n1=lhs.length
        n2=rhs.length
        lhs=replace_free_variable_caller(free_variable,lhs[1..n1-2],new_term)
        rhs=replace_free_variable_caller(free_variable,rhs[1..n2-2],new_term)
        return "["+lhs+"]"+"["+rhs+"]"
    elsif term.length==1 && letter?(term)==true
        if term==free_variable
            return new_term
        else
            return term
        end
    else
        return term
    end    
end

def replace_free_variable()
    puts "Enter lambda term"
    term=gets.chomp()
    term.delete(' ')
    puts "Enter free variable to be replaced"
    free_variable=gets.chomp()
    free_variable.delete(' ')
    puts "Enter lambda term which has to replace free variable"
    new_term=gets.chomp()
    new_term.delete(' ')
    if is_valid_lambda_term_caller(term)==false
        print "Lambda term ",term," is not a valid lambda term.Please type according to syntax given in README file"
        return
    end
    if is_valid_lambda_term_caller(new_term)==false
        print "Lambda term ",new_term," is not a valid lambda term.Please type according to syntax given in README file so that final term is also a lambda term"
        return
    end
    a=free_terms_caller(term)
    if a.include?(free_variable)==false
        puts "This free variable is not present in this lambda term"
        return
    else
        term=replace_free_variable_caller(free_variable,term,new_term)
        puts "New lambda term after replacing is ",term
        # puts term
    end
end

def beta_reduce_caller(term)
    n=term.length
    if term.length==1 && letter?(term)==true
        return term
    elsif term[0]=="("
        return term
    elsif  term[0]=="["
        lhs="["
        rhs=""
        left_count=1
        flag=0
        for i in (1...n)
            if flag==0
                lhs+=term[i]
            elsif flag==1
                rhs+=term[i]
            else
                return ""
            end

            if term[i]=="["
                left_count+=1
            elsif term[i]=="]"
                left_count-=1
            end
            if left_count==0
                if flag==0
                    flag=1
                else
                    flag=2
                end
            end
        end
        # puts lhs
        # puts rhs
        n1=lhs.length
        n2=rhs.length
        # return is_valid_lambda_term_caller(rhs[1..n2-2]) && is_valid_lambda_term_caller(lhs[1..n1-2])
        y=lhs[1..n1-2]
        z=rhs[1..n2-2]
        if is_abstraction(y)
            return beta_reduce_caller(beta_reduce_abstraction(y,z))
        else
            return term
        end
    else
        return term
    end
end

def beta_reduce(term)
    if is_valid_lambda_term_caller(term)==false
        puts "Not a valid term according to given syntax.Please go through README file to see correct syntax and type according to it\n"
    else
        a=beta_reduce_caller(term)
        puts "Reduced term is"
        puts a
    end
end

#file_input
File.open("test_checker.txt").each do|line|
    x=line
    x=x.chomp()
    x=x.delete(' ')
    print "For the lambda term ",x,"\n"
    puts is_valid_lambda_term(x)
    puts free_terms(x)
    puts beta_reduce(x)
end

#terminal_input

# puts "Give lambda term as input"
# x=gets.chomp()
# x=x.delete(' ')
# puts is_valid_lambda_term(x)

# puts free_terms(x)

# puts beta_reduce(x)


# to run question 3 i.e. replace free variable comment down below code

# replace_free_variable()
